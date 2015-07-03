class Order::LineItem < ActiveRecord::Base
  # self.table_name = 'order_line_items'
  belongs_to :order, class_name: '::Order', inverse_of: :line_items, touch: true
  belongs_to :product, class_name: '::Product', inverse_of: :order_line_items

  validates :order, presence: true
  validates :product, presence: true, uniqueness: { scope: :order }
  validates :quantity, presence: true, numericality: true
  validates :amount, presence: true, numericality: { less_than_or_equal_to: 99999999 }

  # Initializes a new LineLineItem
  def initialize(options = {})
    self.quantity = options[:quantity] || 1
    self.price = options[:price] || 0.00
  end

  # For rendering title in Rails Admin
  def title
    "#{product.name} - #{quantity} #{product.uom} - #{order.currency.code} #{amount}"
  end

  def amount
    price * quantity
  end
end
