class Order < ActiveRecord::Base
  belongs_to :currency, inverse_of: :orders
  belongs_to :booked_by, class_name: 'User', foreign_key: 'booked_by_id', inverse_of: :booked_orders
  has_many :line_items, class_name: 'Order::LineItem', inverse_of: :order, dependent: :restrict_with_exception

  accepts_nested_attributes_for :line_items

  validates :currency, presence: true
  validates :booked_by, presence: true
  validates :amount, presence: true, numericality: { less_than_or_equal_to: 99999999 }
  validates :number, presence: true, length: { in: 1..10 }, uniqueness: { case_sensitive: false }
  validates :active, inclusion: { in: [true, false] }

  before_validation :ensure_currency_presence

  before_save :update_amount_from_line_items

  def update_amount_from_line_items
    line_items.reject(&:marked_for_destruction?).sum(&:amount)
  end

  def ensure_currency_presence
    self.currency_id = 1 if self.currency.blank? # INR by default
  end
end
