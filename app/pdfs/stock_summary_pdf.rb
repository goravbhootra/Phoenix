class StockSummaryPdf < Prawn::Document
  def initialize()
    super({top_margin: 25, left_margin: 20, right_margin: 15, bottom_margin: 20})
    text GlobalSettings.organisation_name, size: 15, style: :bold, align: :center
    stroke_horizontal_rule
    move_down 10
    text "Generated at: #{ Time.zone.now.to_formatted_s(:long) }", size: 12
    BusinessEntityLocation.where(business_entity_id: 3).each do |business_entity_location|
      move_down 10
      text "BusinessEntityLocation: #{business_entity_location.name}"
      render_table(business_entity_location.id)
      start_new_page
    end
  end

  def render_table(business_entity_location_id)
    move_down 10
    table balance_stock(business_entity_location_id) do
      row(0).font_style = :bold
      columns(0).align = :center
      columns(1).align = :left
      columns(2..6).align = :center
      row(0).align = :center
      # self.row_colors = ["DDDDDD", "FFFFFF"]
      self.width = 580
      self.cell_style = { size: 10, padding_left: 5, padding_right: 5 }
      self.header = true
    end
  end

  def total_sales(business_entity_location_id)
    sale_product_ids_qty_hash = {}
    InventoryOutVoucherLineItem.all.map { |x| sale_product_ids_qty_hash.keys.include?(x.product_id) ? sale_product_ids_qty_hash[x.product_id] += -x.quantity : sale_product_ids_qty_hash[x.product_id] = -x.quantity }
    sale_product_ids_qty_hash
  end

  def balance_stock(business_entity_location_id)
    result = Array.new
    incoming = opening_stock_and_receipts(business_entity_location_id)
    outgoing = total_sales(business_entity_location_id)

    (incoming.keys + outgoing.keys).uniq.each do |key|
      product = Product.includes([:language, :category]).find(key)
      result += [[product.sku, product.name, product.language_code, product.category.parent.present? ? product.category.parent.code : product.category.code, incoming[key].to_i, -outgoing[key].to_i, incoming[key].to_i+outgoing[key].to_i]]
    end
    result = result.sort_by { |x| [x[3], [x[2].present? ? x[2] : ''], x[0]] }
    result.unshift(['SKU', "Product", "Lang", 'P. Cat.', "BS In Qty", "Total Sale", "BS Bal. Qty", ])
  end

  def opening_stock_and_receipts(business_entity_location_id)
    opening_stock_product_ids_quantity_hash = {}
    InventoryTxn.where(classification: 2).map do |voucher|
      voucher.line_items.all.map { |x| opening_stock_product_ids_quantity_hash.keys.include?(x.product_id) ? opening_stock_product_ids_quantity_hash[x.product_id] += -x.quantity : opening_stock_product_ids_quantity_hash[x.product_id] = -x.quantity }
    end
    opening_stock_product_ids_quantity_hash
  end
end
