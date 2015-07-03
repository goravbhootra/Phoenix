class InvoicePayment < ActiveRecord::Base
  belongs_to :invoice, inverse_of: :payments, touch: true
  belongs_to :mode, class_name: 'PaymentMode', inverse_of: :invoice_payments
  belongs_to :received_by, class_name: 'User', foreign_key: 'received_by_id', inverse_of: :received_payments

  attr_accessor :bank_name, :card_last_digits, :expiry_month, :expiry_year, :mobile_number, :card_holder_name

  validates :invoice, presence: true
  validates :mode, presence: true, uniqueness: { scope: :invoice }
  validates :received_by, presence: true
  validates :amount, presence: true, numericality: { less_than_or_equal_to: 99999999 }
  validates :bank_name, length: { in: 2..70 }, allow_nil: true, allow_blank: true
  validates :card_last_digits, numericality: { greater_than_or_equal_to: 1000, less_than_or_equal_to: 9999 }, allow_nil: true, allow_blank: true
  validates :expiry_month, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 12 }, allow_nil: true, allow_blank: true
  validates :expiry_year, numericality: { greater_than_or_equal_to: 2015, less_than_or_equal_to: 2025 }, allow_nil: true, allow_blank: true
  validates :card_holder_name, length: { in: 3..70 }, allow_nil: true, allow_blank: true
end
