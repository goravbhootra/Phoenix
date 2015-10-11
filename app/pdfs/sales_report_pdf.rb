class SalesReportPdf < Prawn::Document
  def initialize(pos_invoice_line_items)
    super({top_margin: 25, left_margin: 20, right_margin: 15, bottom_margin: 20})
    text GlobalSettings.organisation_name, size: 15, style: :bold, align: :center
    move_down 10
    text "Total Sales", size: 15, align: :center
    move_down 5
    generated_date
    stroke_horizontal_rule
    @pos_invoice_line_items = pos_invoice_line_items
    line_items
  end

  def generated_date
    move_down 10
    text "Generated at: #{ Time.zone.now.to_formatted_s(:long) }", size: 12
  end

  def line_items
    move_down 10
    table line_item_rows do
      row(0).font_style = :bold
      columns(0).align = :center
      columns(0).width = 70
      columns(1).align = :left
      columns(1).width = 290
      columns(2..3).align = :center
      columns(2..3).width = 70
      column(4).align = :right
      columns(4).width = 80
      row(0).align = :center
      # self.row_colors = ["DDDDDD", "FFFFFF"]
      self.width = 580
      # column_widths = [ 0 => 80, 1 => 80, 2 => 80, 3 => 80 ]
      self.cell_style = { size: 12, padding_left: 20, padding_right: 20 }
      self.header = true
    end
  end

  def line_item_rows
    result = Array.new
    a = {}
    @pos_invoice_line_items.find_each.map { |x| a.keys.include?(x.product_id) ? a[x.product_id] -= x.quantity : a[x.product_id] = -x.quantity } # Pos invoice quantity is stored as negative
    a = a.sort_by { |k| k }.to_h
    a.keys.each do |key|
      product = Product.find(key)
      result += [[product.sku, product.name, product.language_code, a[key], '']]
    end
    result = result.sort_by { |x| [x[2].present? ? x[2] : '', x[3]] }
    result.unshift(['SKU', "Product", "Lang", "Qty", "Iss.Qty"])
  end
end
