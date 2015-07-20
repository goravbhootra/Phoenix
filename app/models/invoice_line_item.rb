class InvoiceLineItem < ActiveRecord::Base
  belongs_to :account_txn, inverse_of: :line_items, touch: true
  belongs_to :product, inverse_of: :invoice_line_items
  belongs_to :state_category_tax_rate, inverse_of: :invoice_line_items

  validates :account_txn, presence: true
  validates :product, presence: true, uniqueness: { scope: :account_txn }
  validates :tax_rate, presence: true, numericality: { in: 0..100 }
  validates :quantity, presence: true, numericality: { only_integer: true, less_than_or_equal_to: 9999999 }
  validates :price, presence: true, numericality: { less_than_or_equal_to: 99999999 }
  validates :goods_value, presence: true, numericality: { less_than_or_equal_to: 99999999 }
  validates :tax_rate, presence: true, numericality: { in: 0..100 }
  validates :tax_amount, presence: true, numericality: { less_than_or_equal_to: 99999999 }
  validates :amount, presence: true, numericality: { less_than_or_equal_to: 99999999 }

  delegate :voucher_print_name, to: :product, allow_nil: true
  delegate :selling_price, to: :product, allow_nil: true

  def initialize(attributes={})
    super
    self.tax_rate = self.tax_rate.presence || BigDecimal('0')
    self.tax_amount = self.tax_amount.presence || BigDecimal('0')
    self.goods_value = self.goods_value.presence || amount
  end
end
