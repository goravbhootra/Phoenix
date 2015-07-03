class InventoryVoucherLineItem < ActiveRecord::Base
  # self.table_name = 'inventory_voucher_line_items'
  belongs_to :inventory_voucher, inverse_of: :line_items, touch: true
  belongs_to :product, inverse_of: :inventory_voucher_line_items

  validates :inventory_voucher, presence: true
  validates :product, presence: true, uniqueness: { scope: :inventory_voucher }
  validates :quantity, presence: true, numericality: true
  validates :amount, presence: true, numericality: { less_than_or_equal_to: 99999999 }
  validates :price, presence: true, numericality: { less_than_or_equal_to: 99999999 }

  delegate :voucher_print_name, to: :product, allow_nil: true
  delegate :selling_price, to: :product, allow_nil: true
end
