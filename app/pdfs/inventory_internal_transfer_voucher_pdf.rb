class InventoryInternalTransferVoucherPdf < Prawn::Document
  def initialize(inventory_internal_transfer_voucher)
    super({top_margin: 20, left_margin: 35, right_margin: 25, bottom_margin: 20})
    text "Spiritual Hierarchy Publication Trust", size: 15, style: :bold, align: :center
    text "Babuji Memorial Ashram, Manapakkam, Chennai", size: 13, align: :center
    stroke_horizontal_rule
    @inventory_internal_transfer_voucher = inventory_internal_transfer_voucher
    inventory_internal_transfer_voucher_number
    voucher_header
    line_items
    voucher_totals
  end

  def voucher_header
    move_down 10
    text "From Entity-Location: #{@inventory_internal_transfer_voucher.primary_location.entity_name_with_location}"
    move_down 5
    text "To location: #{@inventory_internal_transfer_voucher.secondary_location_name}"
    move_down 10
    text "Created by: #{@inventory_internal_transfer_voucher.created_by.custom_object_label}"
    move_down 10
    text "Remarks: #{@inventory_internal_transfer_voucher.remarks}"
    move_down 10
  end

  def inventory_internal_transfer_voucher_number
    move_down 20
    text "Inventory Internal Transfer Voucher \# #{@inventory_internal_transfer_voucher.number_prefix} #{@inventory_internal_transfer_voucher.number}", size: 15, style: :bold, align: :center
    move_down 10
    text "Dated: #{@inventory_internal_transfer_voucher.voucher_date.strftime('%d/%m/%Y')}", size: 13
  end

  def line_items
    move_down 10
    table line_item_rows do
      row(0).font_style = :bold
      columns(0).align = :center
      columns(0).width = 60
      columns(1).align = :left
      columns(1).width = 250
      columns(2..3).align = :center
      columns(2).width = 60
      columns(3).width = 60
      column(4).align = :right
      columns(4).width = 60
      column(5).align = :right
      columns(5).width = 70
      row(0).align = :center
      # self.row_colors = ["DDDDDD", "FFFFFF"]
      self.width = 560
      self.cell_style = { size: 13, padding_left: 10, padding_right: 10 }
      self.header = true
    end
  end

  def line_item_rows
    result = [['SKU', "Product", "Qty Sent", "Qty Recd", "Price", "Amount"]]
    @inventory_internal_transfer_voucher.line_items.map do |item|
      next if !item.persisted?
      result += [[item.product_sku, item.voucher_label, item.quantity_out, item.quantity_in, (sprintf '%.0f', item.price), (sprintf '%.0f', item.amount)]]
    end
    result
  end

  def voucher_totals
    move_down 25
    indent(290) do
      text "Total Quantity: #{@inventory_internal_transfer_voucher.line_items.total_quantity}", size: 14, style: :bold
      text "Total Amount: #{(sprintf '%.2f', @inventory_internal_transfer_voucher.line_items.total_amount)}", size: 14, style: :bold
    end
  end
end
