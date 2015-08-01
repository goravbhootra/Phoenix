class Invoice < AccountTxn
  accepts_nested_attributes_for :header, allow_destroy: true
  accepts_nested_attributes_for :line_items, allow_destroy: true, reject_if: :mandatory_values_check

  before_validation :check_header_exists_and_populate
  before_validation :convert_quantity_to_negative
  before_validation :consolidate_line_items_on_product
  before_validation :populate_sales_account_and_amount

  delegate :location_entity_name, to: :header, prefix: false
  delegate :business_entity_location_name, to: :header, prefix: false
  delegate :name, to: :created_by, prefix: true, allow_nil: true

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

  ### defined in account_txn.rb ###
  def has_debit_entries?
    errors[:base] << 'Payment detail needs to be entered against the invoice' if self.debit_entries.blank? || debit_entries.total_amount <= 0
  end

  def has_credit_entries?
    errors[:base] << 'No products added! Total amount should be more than 0' if self.credit_entries.blank? || credit_entries.total_amount <= 0
  end

  def entries_cancel?
    errors[:base] << 'Payment is not equal to Invoice amount' if credit_entries.total_amount != debit_entries.total_amount
  end
  ### end of defined in account_txn.rb ###

  def mandatory_values_check(attributed)
    if attributed['product_id'].blank? || attributed['quantity'].to_i < 1
      # handle new records with invalid data
      return true if attributed['id'].blank?

      # handle existing records with invalid data
      attributed['_destroy'] = true if attributed['id'].present?
    end
    false
  end

  def populate_sales_account_and_amount
    sales_entries = credit_entries.sales_entries
    errors[:base] << 'Invoice cannot have multiple sales account' and return if sales_entries.size > 1
    if sales_entries.blank?
      entry = self.credit_entries.build(mode: 'Account::SalesAccount')
    else
      entry = sales_entries.first
    end
    entry.amount = VoucherCalculations.new({voucher: self, quantity_field: 'quantity'}).calculate_invoice_total
    entry.account_id = header.business_entity_location.sales_account_id
    errors[:base] << 'Sale amount should be greater than 0' and return if entry.amount.to_i == 0
  end

  def convert_quantity_to_negative
    self.line_items.reject(&:marked_for_destruction?).each { |x| x.quantity = -x.quantity if x.quantity.to_i > 0 }
  end

  def total_quantity
    line_items.total_quantity
  end

  def total_amount
    line_items.total_amount
  end

  def payments_order_type_desc
    entries.order("type DESC").payment_entries
  end
end
