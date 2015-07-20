class InventoryReport < ActiveType::Object
  # http://localhost:3000/stock-summary.xls?location_id=153&from_date='17/07/2015'&to_date='17/07/2015'

  # attribute :from_date, :date
  # attribute :to_date, :date
  # attribute :location_id, :integer

  # # validates :from_date, :to_date, presence: true
  # validates :location_id, numericality: true, allow_blank: true, allow_nil: true

  def self.locationwise_stock_summary(options = {}, filter_params={})
    from_date = filter_params[:from_date]
    to_date = filter_params[:to_date]
    location_id = filter_params[:location_id]

    master = Hash.new
    master, opening_stock_products = locationwise_opening_stock_vouchers_consolidated(master, from_date, location_id)
    master, inventory_in_products = locationwise_inventory_in_vouchers_within_period(master, from_date, to_date, location_id)
    master, inventory_out_products = locationwise_inventory_out_vouchers_within_period(master, from_date, to_date, location_id)
    master, pos_sales_products = locationwise_pos_invoices_within_period(master, from_date, to_date, location_id) # pos quantity fetched as positive, stored negative in DB
    master, in_transit_products = locationwise_in_transit_within_period(master, from_date, to_date, location_id)

    product_skus = (opening_stock_products + inventory_in_products + inventory_out_products + pos_sales_products + in_transit_products).uniq
    # product_skus = (opening_stock_products + inventory_in_products + inventory_out_products +  in_transit_products).uniq

    products = Product.sort_skus_by_parentcat_lang(product_skus)
    bus_ent_locs = Hash.new
    BusinessEntityLocation.includes(:business_entity).where(id: master.keys).each { |x| bus_ent_locs[x.id] = [x.business_entity_alias_name, x.name] }
    bus_ent_locs = bus_ent_locs.sort_by { |_,value| value }.to_h

    CSV.generate(options) do |csv|
      csv << ['Bus. Entity', 'Location', 'SKU', 'Product Name', 'P. Cat', 'Lang', 'Op. Stk', 'Inv. Voucher In', 'Inv. Voucher Out', 'POS Sales', 'In Transit', 'Avlbl Stk']
      # csv << ['Bus. Entity', 'Location', 'SKU', 'Product Name', 'P. Cat', 'Lang', 'Op. Stk', 'Inv. Voucher In', 'Inv. Voucher Out', 'In Transit', 'Avlbl Stk']
      bus_ent_locs.keys.each do |loc| # Locations already in sorted order
        master[loc].keys.sort.each do |product|
          available_stock = 0
          available_stock += master[loc][product]['opening_stock'].to_i
          available_stock += master[loc][product]['inventory_in'].to_i
          available_stock -= master[loc][product]['inventory_out'].to_i
          available_stock -= master[loc][product]['pos_sales'].to_i
          available_stock -= master[loc][product]['in_transit'].to_i

          csv << [bus_ent_locs[loc][0],
                  bus_ent_locs[loc][1],
                  product, products[product][0],
                  products[product][1],
                  products[product][2],
                  master[loc][product]['opening_stock'],
                  master[loc][product]['inventory_in'],
                  master[loc][product]['inventory_out'],
                  master[loc][product]['pos_sales'],
                  (master[loc][product]['in_transit'].present? && master[loc][product]['in_transit'] != 0) ? master[loc][product]['in_transit'] : nil,
                  available_stock]
        end
      end
    end
  end

  def self.locationwise_opening_stock_vouchers_consolidated(master=Hash.new, from_date='01/04/2015', location_id=nil)
      inventory = Hash.new
      if location_id.present?
        inventory['in'] = InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInVoucher.where(primary_location_id: location_id).where("date(voucher_date) < ?", Date.parse(from_date)).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_in)

        inventory['out'] = InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryOutVoucher.where(primary_location_id: location_id).where("date(voucher_date) < ?", Date.parse(from_date)).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_out)

        inventory['transit_out'] = InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInternalTransferVoucher.where(primary_location_id: location_id).where("date(voucher_date) < ?", Date.parse(from_date)).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_out)

        inventory['transit_in'] = InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInternalTransferVoucher.where(secondary_location_id: location_id).where("date(voucher_date) < ?", Date.parse(from_date)).pluck(:id)).includes(:product, :inventory_txn).group(:secondary_location_id, :sku).order("secondary_location_id, products.sku").sum(:quantity_in)
      else
        inventory['in'] = InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInVoucher.where("date(voucher_date) < ?", Date.parse(from_date)).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_in)

        inventory['out'] = InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryOutVoucher.where("date(voucher_date) < ?", Date.parse(from_date)).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_out)

        inventory['transit_out'] = InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInternalTransferVoucher.where("date(voucher_date) < ?", Date.parse(from_date)).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_out)

        inventory['transit_in'] = InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInternalTransferVoucher.where("date(voucher_date) < ?", Date.parse(from_date)).pluck(:id)).includes(:product, :inventory_txn).group(:secondary_location_id, :sku).order("secondary_location_id, products.sku").sum(:quantity_in)
      end
      all_keys = (inventory['in'].keys + inventory['out'].keys + inventory['transit_in'].keys + inventory['transit_out'].keys).uniq

      inventory['consolidated'] = Hash.new

      all_keys.each do |key|
        inventory['consolidated'][key] = inventory['in'][key].to_i - inventory['out'][key].to_i + inventory['transit_in'][key].to_i - inventory['transit_out'][key].to_i
      end
      hash_reorganise_locatiowise(master, 'opening_stock', inventory['consolidated'])
  end

  # def self.locationwise_opening_stock_vouchers_consolidated(master=Hash.new)
  #   # BusinessEntity(128) - Opening Stock
  #   hash_reorganise_locatiowise(master, 'opening_stock',
  #                       InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryTxn.where(secondary_entity_id: 128).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_in)
  #                               )
  # end

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

  def self.locationwise_inventory_in_vouchers_within_period(master=Hash.new, from_date='01/04/2015', to_date=Time.zone.now.strftime('%d/%m/%Y'), location_id=nil)
    if location_id.present?
      inv_in_vouchers, prods_in = hash_reorganise_locatiowise(master, 'inventory_in',
                                InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInVoucher.where("date(voucher_date) >= ? AND date(voucher_date) <= ?", Date.parse(from_date), Date.parse(to_date)).where(primary_location_id: location_id).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_in)
                                )
      int_tnsfr_in, prods_tnsfr = hash_reorganise_locatiowise({}, 'inventory_in',
                                InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInternalTransferVoucher.where("date(voucher_date) >= ? AND date(voucher_date) <= ?", Date.parse(from_date), Date.parse(to_date)).where(secondary_location_id: location_id).pluck(:id)).includes(:product, :inventory_txn).group(:secondary_location_id, :sku).order("secondary_location_id, products.sku").sum(:quantity_in)
                                )
    else
      inv_in_vouchers, prods_in = hash_reorganise_locatiowise(master, 'inventory_in',
                                InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInVoucher.where("date(voucher_date) >= ? AND date(voucher_date) <= ?", Date.parse(from_date), Date.parse(to_date)).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_in)
                                )
      int_tnsfr_in, prods_tnsfr = hash_reorganise_locatiowise({}, 'inventory_in',
                                InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInternalTransferVoucher.where("date(voucher_date) >= ? AND date(voucher_date) <= ?", Date.parse(from_date), Date.parse(to_date)).pluck(:id)).includes(:product, :inventory_txn).group(:secondary_location_id, :sku).order("secondary_location_id, products.sku").sum(:quantity_in)
                                )
    end
    int_tnsfr_in.keys.each do |loc|
      int_tnsfr_in[loc].keys.each do |prod|
        inv_in_vouchers[loc] || inv_in_vouchers[loc] = Hash.new
        inv_in_vouchers[loc][prod] || inv_in_vouchers[loc][prod] = Hash.new
        if inv_in_vouchers[loc][prod]['inventory_in'].present?
          inv_in_vouchers[loc][prod]['inventory_in'] += int_tnsfr_in[loc][prod]['inventory_in']
        else
          inv_in_vouchers[loc][prod]['inventory_in'] = int_tnsfr_in[loc][prod]['inventory_in']
        end
      end
    end
    return inv_in_vouchers, (prods_in + prods_tnsfr).uniq.sort
  end

  def self.locationwise_inventory_out_vouchers_within_period(master=Hash.new, from_date='01/04/2015', to_date=Time.zone.now.strftime('%d/%m/%Y'), location_id=nil)
    if location_id.present?
      inv_out_vouchers, prods_out = hash_reorganise_locatiowise(master, 'inventory_out',
                            InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryOutVoucher.where("date(voucher_date) >= ? AND date(voucher_date) <= ?", Date.parse(from_date), Date.parse(to_date)).where(primary_location_id: location_id).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_out)
                                )
      int_tnsfr_out, prods_tnsfr = hash_reorganise_locatiowise({}, 'inventory_out',
                            InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInternalTransferVoucher.where("date(voucher_date) >= ? AND date(voucher_date) <= ?", Date.parse(from_date), Date.parse(to_date)).where(primary_location_id: location_id).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_out)
                                )
    else
      inv_out_vouchers, prods_out = hash_reorganise_locatiowise(master, 'inventory_out',
                            InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryOutVoucher.where("date(voucher_date) >= ? AND date(voucher_date) <= ?", Date.parse(from_date), Date.parse(to_date)).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_out)
                                )
      int_tnsfr_out, prods_tnsfr = hash_reorganise_locatiowise({}, 'inventory_out',
                            InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInternalTransferVoucher.where("date(voucher_date) >= ? AND date(voucher_date) <= ?", Date.parse(from_date), Date.parse(to_date)).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_out)
                                )
    end
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

  def self.locationwise_in_transit_within_period(master=Hash.new, from_date='01/04/2015', to_date=Time.zone.now.strftime('%d/%m/%Y'), location_id=nil)
    if location_id.present?
      hash_reorganise_locatiowise(master, 'in_transit',
                            InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInternalTransferVoucher.where("date(voucher_date) >= ? AND date(voucher_date) <= ?", Date.parse(from_date), Date.parse(to_date)).where(primary_location_id: location_id).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum("quantity_out - quantity_in")
                            )
    else
      hash_reorganise_locatiowise(master, 'in_transit',
                            InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInternalTransferVoucher.where("date(voucher_date) >= ? AND date(voucher_date) <= ?", Date.parse(from_date), Date.parse(to_date)).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum("quantity_out - quantity_in")
                            )
    end
  end

  def self.locationwise_pos_invoices_within_period(master=Hash.new, from_date='01/04/2015', to_date=Time.zone.now.strftime('%d/%m/%Y'), location_id=nil)
    # pos quantity returned as positive, stored negative in DB
    if location_id.present?
      hash_reorganise_locatiowise(master, 'pos_sales',
                                InvoiceLineItem.where("invoice_line_items.account_txn_id IN (?)", PosInvoice.joins(:header).where("date(txn_date) >= ? AND date(txn_date) <= ?", Date.parse(from_date), Date.parse(to_date)).where("invoice_headers.business_entity_location_id = ?", location_id).references("invoice_headers").pluck(:id)).includes(:product, account_txn: :header).group(:business_entity_location_id, :sku).order("business_entity_location_id, products.sku").sum("-quantity")
                                )
    else
      hash_reorganise_locatiowise(master, 'pos_sales',
                                InvoiceLineItem.where("invoice_line_items.account_txn_id IN (?)", PosInvoice.where("date(txn_date) >= ? AND date(txn_date) <= ?", Date.parse(from_date), Date.parse(to_date)).pluck(:id)).includes(:product, account_txn: :header).group(:business_entity_location_id, :sku).order("business_entity_location_id, products.sku").sum("-quantity")
                                )
    end
  end

  def self.locationwise_inventory_out_vouchers_without_reserved_accounts_consolidated(master=Hash.new)
    # All records except following
    # BusinessEntity(105) - Retail Sales, BusinessEntity(129) - Corpus Distribution, BusinessEntity(130) - Gratis Distribution
    hash_reorganise_locatiowise(master, 'inventory_out_wo_reserved',
                                InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryOutVoucher.where("secondary_entity_id NOT IN (105, 129, 130)").pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_out)
                                )
  end

  def self.locationwise_inventory_in_vouchers_consolidated(master=Hash.new)
    hash_reorganise_locatiowise(master, 'inventory_in',
                                InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryInVoucher.pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_in)
                                )
  end

  def self.locationwise_retail_sale_vouchers_consolidated(master=Hash.new)
    # BusinessEntity(105) - Retail Sales
    hash_reorganise_locatiowise(master, 'retail_sales',
                                InventoryTxnLineItem.where('inventory_txn_id IN (?)', InventoryOutVoucher.where(secondary_entity_id: 105).pluck(:id)).includes(:product, :inventory_txn).group(:primary_location_id, :sku).order("primary_location_id, products.sku").sum(:quantity_out)
                                )
  end
end
