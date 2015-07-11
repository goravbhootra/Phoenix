class VoucherCalculations
  def initialize(attributes={})
    @voucher = attributes[:voucher]
    @quantity_field = attributes[:quantity_field]
  end

  def process_totals
    @voucher.total_amount = BigDecimal('0')
    @voucher.line_items.reject(&:marked_for_destruction?).each do |line_item|
      line_item.price = BigDecimal(line_item.product.selling_price.to_s) if line_item.new_record?
      line_item.amount = BigDecimal((line_item.send(@quantity_field).to_i * line_item.price).to_s)
      @voucher.total_amount += line_item.amount
    end
  end

  def calculate_invoice_total
    total_amount = BigDecimal('0')
    @voucher.line_items.reject(&:marked_for_destruction?).each do |line_item|
      line_item.price = BigDecimal(line_item.product.selling_price.to_s) if line_item.new_record?
      line_item.amount = BigDecimal((line_item.send(@quantity_field).to_i * line_item.price).to_s)
      total_amount += line_item.amount
    end
    total_amount
  end
end
