class Invoice < MyActiveRecord
  belongs_to :currency, inverse_of: :invoices
  belongs_to :primary_location, class_name: 'BusinessEntityLocation', inverse_of: :invoices
  belongs_to :secondary_entity, class_name: 'BusinessEntity', inverse_of: :invoices
  belongs_to :voucher_sequence, inverse_of: :invoices
  belongs_to :created_by, class_name: 'User', inverse_of: :created_invoices
  has_many :payments, class_name: 'InvoicePayment', dependent: :destroy, inverse_of: :invoice, autosave: true
  has_many :line_items, class_name: 'InvoiceLineItem', dependent: :destroy,
            inverse_of: :invoice, autosave: true

  validates :currency, presence: true
  validates :created_by_id, :voucher_sequence_id, presence: true
  validates :primary_location_id, :secondary_entity_id, presence: true
  validates :total_amount, :tax_amount, presence: true, numericality: { less_than_or_equal_to: 99999999 }
  validates :number_prefix, length: { maximum: 8 }
  validates :number, presence: true, numericality: true
  validates :number, uniqueness: { scope: :number_prefix, case_sensitive: false }
  validates :number, uniqueness: { scope: :voucher_sequence_id }
  validates :invoice_date, presence: true
  validates :status, presence: true
  validates :ref_number, length: { maximum: 30 }
  validates :goods_value, presence: true, numericality: { less_than_or_equal_to: 99999999 }

  attr_accessor :current_user_id#, payments_attributes: [:bank_name, :card_last_digits, :expiry_month, :expiry_year, :mobile_number, :card_holder_name]

  accepts_nested_attributes_for :line_items, allow_destroy: true, reject_if: :mandatory_values_check

  accepts_nested_attributes_for :payments, allow_destroy: true, reject_if: :payment_mandatory_values_check

  enum status: { 'Active': 1, 'Cancelled': 2, 'Approval Required': 3 }

  delegate :name, to: :created_by, prefix: true, allow_nil: true
  delegate :entity_name_with_location, to: :primary_location, allow_nil: true
  delegate :alias_name, to: :secondary_entity, prefix: true, allow_nil: true

  scope :created_by_user, -> (user_id) { where(created_by_id: user_id) }

  before_validation :set_defaults
  before_validation :convert_quantity_to_negative
  before_validation :consolidate_line_items_on_product
  before_validation :process_calculations
  before_validation :payment_checks_and_credit_card_info

  before_create :set_number

  def initialize(attributes={})
    super
    self.created_by_id = current_user_id if self.created_by_id.blank?
    self.currency_id = attributes[:currency_id].presence || 1 # Default INR
    self.status = attributes[:status].presence || 1 # Default Active
    self.number = attributes[:number].presence || 0 # Pre-filled for new invoice
    self.tax_amount = attributes[:tax_amount].presence || BigDecimal('0')
  end

  def set_defaults
    self.created_by_id = current_user_id if self.created_by_id.blank?
  end

  def payment_checks_and_credit_card_info
  end

  def payment_mandatory_values_check(attributed)
  end

  def mandatory_values_check(attributed)
  end

  def consolidate_line_items_on_product
  end

  def convert_quantity_to_negative
  end

  def set_number
    begin
      self.number = Invoice.where(voucher_sequence_id: self.voucher_sequence_id).maximum(:number).to_i.succ if self.number.blank? || self.number == 0
      self.number_prefix = self.voucher_sequence.number_prefix
    rescue => e
      Airbrake.notify(e)
      errors.add(:base, 'Could not obtain invoice number. Please retry saving.') and return false
    end
  end

  def process_calculations
  end

  def voucher_number
    prefix = number_prefix.presence || ''
    "#{prefix}#{number.to_s.rjust(5, '0')}"
  end

  def total_quantity
    # line_items.pluck(:quantity).inject(0) { |sum,x| sum += x }
    line_items.sum(:quantity)
  end

  def self.product_details_by_ids(product_ids)
    Product.product_details_by_ids(product_ids)
  end
end
