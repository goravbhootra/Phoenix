class Invoice < AccountTxn
  accepts_nested_attributes_for :header, allow_destroy: true
  accepts_nested_attributes_for :line_items, allow_destroy: true, reject_if: :mandatory_values_check

  before_validation :check_header_exists_and_populate
  before_validation :convert_quantity_to_negative
  before_validation :consolidate_line_items_on_product
  before_validation :populate_sales_amount

  delegate :location, to: :header, prefix: false, allow_nil: true

  # def initialize(attributes={})
  #   super
  #   self.status = attributes[:status].presence || 1 # Default Active
  #   self.number = attributes[:number].presence || 0 # Pre-filled for new invoice
  # end

  def check_header_exists_and_populate
    self.header.business_entity_location_id = 154 if self.header.business_entity_location_id.blank?
  end

  def consolidate_line_items_on_product
    VoucherConsolidateLineItems.new({voucher: self, association_name: 'line_items', attrib_id: 'product_id', consolidate: 'quantity'}).consolidate_with_same_attribute
  end

  def total_quantity
    line_items.total_quantity
  end

  def total_amount
    line_items.total_amount
  end

  def payments
    entries.payments
  end

  def mandatory_values_check(attributed)
  end

  def populate_sales_amount
  end

  def convert_quantity_to_negative
  end
end
