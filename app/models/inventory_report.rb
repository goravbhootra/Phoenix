class InventoryReport < ActiveType::Object

  def self.locationwise_stock_summary(options = {})
    master = Hash.new
    master, opening_stock_products = locationwise_opening_stock_vouchers_consolidated(master)
    master, inventory_in_products = locationwise_inventory_in_vouchers_except_opening_stock_consolidated(master)
    master, inventory_out_products = locationwise_inventory_out_vouchers_consolidated(master)
    master, pos_sales_products = locationwise_pos_invoices_consolidated(master)
    master, in_transit_products = locationwise_in_transit_consolidated(master)

    product_skus = (opening_stock_products + inventory_in_products + inventory_out_products + pos_sales_products + in_transit_products).uniq

    products = Product.sort_skus_by_parentcat_lang(product_skus)
    bus_ent_locs = Hash.new
    BusinessEntityLocation.includes(:business_entity).where(id: master.keys).each { |x| bus_ent_locs[x.id] = [x.business_entity_alias_name, x.name] }
    bus_ent_locs = bus_ent_locs.sort_by { |_,value| value }.to_h

    CSV.generate(options) do |csv|
      csv << ['Bus. Entity', 'Location', 'SKU', 'Product Name', 'P. Cat', 'Lang', 'Op. Stk', 'Inv. Voucher In', 'Inv. Voucher Out', 'POS Sales', 'In Transit', 'Avlbl Stk']
      bus_ent_locs.keys.each do |loc| # Locations already in sorted order
        master[loc].keys.sort.each do |product|
          available_stock = 0
          available_stock += master[loc][product]['opening_stock'].to_i
          available_stock += master[loc][product]['inventory_in_wo_opening_stock'].to_i
          available_stock -= master[loc][product]['inventory_out'].to_i
          available_stock += master[loc][product]['pos_sales'].to_i # pos quantity is in -ve
          available_stock -= master[loc][product]['in_transit'].to_i

          csv << [bus_ent_locs[loc][0],
                  bus_ent_locs[loc][1],
                  product, products[product][0],
                  products[product][1],
                  products[product][2],
                  master[loc][product]['opening_stock'],
                  master[loc][product]['inventory_in_wo_opening_stock'],
                  master[loc][product]['inventory_out'],
                  master[loc][product]['pos_sales'].present? ? -master[loc][product]['pos_sales'] : nil,
                  (master[loc][product]['in_transit'].present? && master[loc][product]['in_transit'] != 0) ? master[loc][product]['in_transit'] : nil,
                  available_stock]
        end
      end
    end
  end

  def self.hash_reorganise_locatiowise(master=Hash.new, key_name='not_specified', hsh=Hash.new)
    products = Array.new
    hsh.each do |key,value|
      master[key[0]] || master[key[0]] = Hash.new
      master[key[0]][key[1]] || master[key[0]][key[1]] = Hash.new
      master[key[0]][key[1]][key_name] = value
      products << key[1]
    end
    return master, products.uniq.sort
  end

  def self.locationwise_pos_invoices_consolidated(master=Hash.new)
    hash_reorganise_locatiowise(master, 'pos_sales',
                                InvoiceLineItem.where("invoice_id IN (?)", PosInvoice.pluck(:id)).includes(:product, :invoice).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity)
                                )
    # sales = {}
    # product_ids = {}
    # PosInvoice.find_each do |invoice|
    #   li_data = invoice.line_items.pluck(:product_id, :quantity)
    #   sales["#{invoice.primary_location_id}"] = {} if sales.keys.exclude?("#{invoice.primary_location_id}")
    #   li_data.each do |rec|
    #     sales["#{invoice.primary_location_id}"][rec[0]] = sales["#{invoice.primary_location_id}"][rec[0]].to_i + rec[1].to_i
    #     product_ids["#{invoice.primary_location_id}"] = [] if product_ids.keys.exclude?("#{invoice.primary_location_id}")
    #     product_ids["#{invoice.primary_location_id}"] << rec[0]
    #   end
    #   product_ids["#{invoice.primary_location_id}"].uniq!
    # end
    # { 'sales': sales, 'product_ids': product_ids }
  end

  def self.locationwise_retail_sale_vouchers_consolidated(master=Hash.new)
    # BusinessEntity(105) - Retail Sales
    hash_reorganise_locatiowise(master, 'retail_sales',
                                InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryOutVoucher.where(secondary_entity_id: 105).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_out)
                                )
  end

  def self.locationwise_inventory_out_vouchers_without_reserved_accounts_consolidated(master=Hash.new)
    # All records except following
    # BusinessEntity(105) - Retail Sales, BusinessEntity(129) - Corpus Distribution, BusinessEntity(130) - Gratis Distribution
    hash_reorganise_locatiowise(master, 'inventory_out_wo_reserved',
                                InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryOutVoucher.where("secondary_entity_id NOT IN (105, 129, 130)").pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_out)
                                )
  end

  def self.locationwise_inventory_out_vouchers_consolidated(master=Hash.new)
    inv_out_vouchers, prods_out = hash_reorganise_locatiowise(master, 'inventory_out',
                                InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryOutVoucher.pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_out)
                                )
    int_tnsfr_out, prods_tnsfr = hash_reorganise_locatiowise({}, 'inventory_out',
                                InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInternalTransferVoucher.pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_out)
                                )
    int_tnsfr_out.keys.each do |loc|
      int_tnsfr_out[loc].keys.each do |prod|
        inv_out_vouchers[loc] || inv_out_vouchers[loc] = Hash.new
        inv_out_vouchers[loc][prod] || inv_out_vouchers[loc][prod] = Hash.new
        if inv_out_vouchers[loc][prod]['inventory_out'].present?
          inv_out_vouchers[loc][prod]['inventory_out'] += int_tnsfr_out[loc][prod]['inventory_out']
        else
          inv_out_vouchers[loc][prod]['inventory_out'] = int_tnsfr_out[loc][prod]['inventory_out']
        end
      end
    end
    return inv_out_vouchers, (prods_out + prods_tnsfr).uniq.sort
  end

  def self.locationwise_opening_stock_vouchers_consolidated(master=Hash.new)
    # BusinessEntity(128) - Opening Stock
    hash_reorganise_locatiowise(master, 'opening_stock',
                                InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryTxn.where(secondary_entity_id: 128).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_in)
                                )
  end

  def self.locationwise_inventory_in_vouchers_except_opening_stock_consolidated(master=Hash.new)
    # BusinessEntity(128) - Opening Stock - All records except Opening Stock
    inv_in_vouchers, prods_in = hash_reorganise_locatiowise(master, 'inventory_in_wo_opening_stock',
                                InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInVoucher.where.not(secondary_entity_id: 128).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_in)
                                )
    int_tnsfr_in, prods_tnsfr = hash_reorganise_locatiowise({}, 'inventory_in_wo_opening_stock',
                                InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInternalTransferVoucher.pluck(:id)).includes(:product, :inventory_txn).group(:secondary_location_id, :sku).order("secondary_location_id, products.sku").sum(:quantity_in)
                                )
    int_tnsfr_in.keys.each do |loc|
      int_tnsfr_in[loc].keys.each do |prod|
        inv_in_vouchers[loc] || inv_in_vouchers[loc] = Hash.new
        inv_in_vouchers[loc][prod] || inv_in_vouchers[loc][prod] = Hash.new
        if inv_in_vouchers[loc][prod]['inventory_in_wo_opening_stock'].present?
          inv_in_vouchers[loc][prod]['inventory_in_wo_opening_stock'] += int_tnsfr_in[loc][prod]['inventory_in_wo_opening_stock']
        else
          inv_in_vouchers[loc][prod]['inventory_in_wo_opening_stock'] = int_tnsfr_in[loc][prod]['inventory_in_wo_opening_stock']
        end
      end
    end
    return inv_in_vouchers, (prods_in + prods_tnsfr).uniq.sort
  end

  def self.locationwise_inventory_in_vouchers_consolidated(master=Hash.new)
    hash_reorganise_locatiowise(master, 'inventory_in',
                                InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInVoucher.pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_in)
                                )
  end

  def self.locationwise_in_transit_consolidated(master=Hash.new)
    # BusinessEntity(128) - Opening Stock - All records except Opening Stock
    hash_reorganise_locatiowise(master, 'in_transit',
                                InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInternalTransferVoucher.pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum("quantity_out - quantity_in")
                                )
  end

  def self.locationwise_in_transit_consolidated(master=Hash.new)
    # BusinessEntity(128) - Opening Stock - All records except Opening Stock
    hash_reorganise_locatiowise(master, 'in_transit',
                                InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInternalTransferVoucher.pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum("quantity_out - quantity_in")
                                )
  end

  # def self.locationwise_inventory_vouchers_consolidated
  #   opening_stock = {}
  #   transfer_in = {}
  #   transfer_out = {}
  #   in_transit = {}
  #   product_ids = {}
  #   InventoryVoucher.find_each do |voucher|
  #     li_data = voucher.line_items.pluck(:product_id, :quantity, :received_quantity)
  #     if voucher.classification == 'opening_stock'
  #       opening_stock["#{voucher.business_entity_location_id}"] = {} if opening_stock.keys.exclude?("#{voucher.business_entity_location_id}")
  #       li_data.each do |rec|
  #         opening_stock["#{voucher.business_entity_location_id}"][rec[0]] = opening_stock["#{voucher.business_entity_location_id}"][rec[0]].to_i + rec[1].to_i
  #         product_ids["#{voucher.business_entity_location_id}"] = [] if product_ids.keys.exclude?("#{voucher.business_entity_location_id}")
  #         product_ids["#{voucher.business_entity_location_id}"] << rec[0]
  #       end
  #       product_ids["#{voucher.business_entity_location_id}"].uniq! if product_ids["#{voucher.business_entity_location_id}"].present?
  #     elsif voucher.classification == 'intra_business_entity_transfer' ||
  #           voucher.classification == 'inter_business_entity_transfer'
  #       transfer_out["#{voucher.business_entity_location_id}"] = {} if transfer_out.keys.exclude?("#{voucher.business_entity_location_id}")
  #       transfer_in["#{voucher.receiving_business_entity_location_id}"] = {} if voucher.receiving_business_entity_location_id.present? && transfer_in.keys.exclude?("#{voucher.receiving_business_entity_location_id}")
  #       in_transit["#{voucher.business_entity_location_id}"] = {} if in_transit.keys.exclude?("#{voucher.business_entity_location_id}")
  #       li_data.each do |rec|
  #         if voucher.receiving_business_entity_location_id.present? && rec[2].present?
  #           transfer_out["#{voucher.business_entity_location_id}"][rec[0]] = transfer_out["#{voucher.business_entity_location_id}"][rec[0]].to_i + rec[2].to_i
  #           transfer_in["#{voucher.receiving_business_entity_location_id}"][rec[0]] = transfer_in["#{voucher.receiving_business_entity_location_id}"][rec[0]].to_i + rec[2].to_i
  #           in_transit["#{voucher.business_entity_location_id}"][rec[0]] = (in_transit["#{voucher.business_entity_location_id}"][rec[0]].to_i + rec[1].to_i + rec[2].to_i) if -rec[1] > rec[2]
  #         else
  #           in_transit["#{voucher.business_entity_location_id}"][rec[0]] = in_transit["#{voucher.business_entity_location_id}"][rec[0]].to_i + rec[1].to_i
  #         end
  #         product_ids["#{voucher.business_entity_location_id}"] = [] if product_ids.keys.exclude?("#{voucher.business_entity_location_id}")
  #         product_ids["#{voucher.business_entity_location_id}"] << rec[0]
  #       end
  #       product_ids["#{voucher.business_entity_location_id}"].uniq!
  #     elsif voucher.classification == 'corpus_distribution' ||
  #           voucher.classification == 'gratis_distribution'
  #       transfer_out["#{voucher.business_entity_location_id}"] = {} if transfer_out.keys.exclude?("#{voucher.business_entity_location_id}")
  #       li_data.each do |rec|
  #         transfer_out["#{voucher.business_entity_location_id}"][rec[0]] = transfer_out["#{voucher.business_entity_location_id}"][rec[0]].to_i - rec[1].to_i
  #         product_ids["#{voucher.business_entity_location_id}"] = [] if product_ids.keys.exclude?("#{voucher.business_entity_location_id}")
  #         product_ids["#{voucher.business_entity_location_id}"] << rec[0]
  #       end
  #       product_ids["#{voucher.business_entity_location_id}"].uniq!
  #     end
  #   end
  #   { 'opening_stock': opening_stock, 'transfer_in': transfer_in, 'transfer_out': transfer_out, 'in_transit': in_transit, 'product_ids': product_ids }
  # end
end
