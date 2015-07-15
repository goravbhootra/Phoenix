class Invoice < AccountTxn
  has_many :line_items, class_name: 'InvoiceLineItem', extend: InvoiceLineItemsExtension, foreign_key: 'account_txn_id', inverse_of: :invoice, dependent: :restrict_with_exception, autosave: true
  accepts_nested_attributes_for :header, allow_destroy: true, reject_if: :payment_mandatory_values_check
  accepts_nested_attributes_for :line_items, allow_destroy: true, reject_if: :mandatory_values_check

  before_validation :check_header_exists_and_populate
  before_validation :convert_quantity_to_negative
  before_validation :consolidate_line_items_on_product
  before_validation :create_sales_entry

  delegate :location, to: :header, prefix: false, allow_nil: true

  def check_header_exists_and_populate
    build_header if header.blank?
    header.business_entity_location_id = account_txn.current_location.id if header.business_entity_location_id.blank? && account_txn.current_location
  end

  def consolidate_line_items_on_product
    byebug
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

  def payment_mandatory_values_check(attributed)
  end

  def create_sales_entry
  end

  def convert_quantity_to_negative
  end
end
