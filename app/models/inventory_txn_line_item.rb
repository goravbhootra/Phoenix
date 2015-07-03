class InventoryTxnLineItem < ActiveRecord::Base
  belongs_to :inventory_txn, inverse_of: :line_items, touch: true
  belongs_to :product, inverse_of: :inventory_txn_line_items

  validates :inventory_txn, presence: true
  validates :product, presence: true, uniqueness: { scope: :inventory_txn }
  validates :tax_rate, presence: true, numericality: { in: 0..100 }
  # validate  :quantity_in_xor_quantity_out
  validate  :quantity_in_out_check
  validates :quantity_in, :quantity_out, numericality: { only_integer: true }, allow_nil: true, allow_blank: true
  validates :amount, presence: true, numericality: { less_than_or_equal_to: 99999999 }
  validates :price, presence: true, numericality: { less_than_or_equal_to: 99999999 }

  before_validation :update_amounts

  delegate :voucher_print_name, to: :product, allow_nil: true
  delegate :selling_price, to: :product, allow_nil: true

  def initialize(attributes={})
    super
    self.tax_rate = self.tax_rate.presence || BigDecimal('0')
  end

  def update_amounts
    self.tax_amount = self.amount
  end

  # def quantity_in_xor_quantity_out
  #   errors.add(:base, "Either quantity_in or quantity_out must be entered") if !(quantity_in.present? ^ quantity_out.present?)
  # end

  def quantity_in_out_check
    # if [month_day, week_day, hour].compact.count =! 1 - Can handle more than two attributes
    errors.add(:base, "Either quantity_in or quantity_out must be entered") and return if !(quantity_in.present? ^ quantity_out.present?) && self.inventory_txn.secondary_location_id.blank?
    errors.add(:base, "Both, quantity_in and quantity_out, must be entered") and return if (quantity_in.blank? || quantity_out.blank?) && self.inventory_txn.secondary_location_id.present?
  end
end
