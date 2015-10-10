 class InventoryTxn < MyActiveRecord
  belongs_to :primary_entity, class_name: 'BusinessEntity', inverse_of: :inventory_txns
  belongs_to :primary_location, class_name: 'BusinessEntityLocation', inverse_of: :inventory_txns
  belongs_to :secondary_entity, class_name: 'BusinessEntity', inverse_of: :secondary_inventory_txns
  belongs_to :secondary_location, class_name: 'BusinessEntityLocation', inverse_of: :secondary_inventory_txns
  belongs_to :voucher_sequence, inverse_of: :inventory_txns
  belongs_to :created_by, class_name: 'User', inverse_of: :created_inventory_txns
  has_many :line_items, class_name: 'InventoryTxnLineItem', extend: InventoryTxnLineItemsExtension, dependent: :destroy, inverse_of: :inventory_txn, autosave: true

  validates :created_by, :voucher_sequence_id, presence: true
  validates :primary_location_id, :primary_entity_id, presence: true
  validates :type, presence: true
  validate :secondary_entity_xor_location
  validates :total_amount, presence: true, numericality: { less_than_or_equal_to: 99999999 }
  validates :number_prefix, length: { maximum: 8 }
  validates :number, presence: true, numericality: true, uniqueness: { scope: [:voucher_sequence_id, :number_prefix], case_sensitive: false }
  validates :voucher_date, presence: true
  validates :status, presence: true
  validates :ref_number, length: { maximum: 30 }

  accepts_nested_attributes_for :line_items, allow_destroy: true, reject_if: :mandatory_values_check

  before_validation :set_defaults
  before_validation :consolidate_line_items_on_product
  before_validation :process_calculations
  before_validation :set_primary_entity_based_on_location

  before_create :set_number

  attr_accessor :current_user_id

  enum status_enum: { 'Active': 1, 'Draft': 2, 'Waiting Approval': 4 }

  delegate :name, to: :created_by, prefix: true, allow_nil: true
  delegate :entity_name_with_location, to: :primary_location, prefix: 'primary', allow_nil: true
  delegate :alias_name, to: :secondary_entity, prefix: true, allow_nil: true
  delegate :name, to: :secondary_location, prefix: true, allow_nil: true
  delegate :name, to: :primary_location, prefix: true, allow_nil: true
  delegate :name, to: :secondary_entity, prefix: true, allow_nil: true

  scope :created_by_user, -> (user_id) { where(created_by_id: user_id) }

  def initialize(attributes={})
    super
    self.status = attributes[:status].presence || 1 # Default Active
    self.number = attributes[:number].presence || 0 # Pre-filled for new invoice
  end

  def set_defaults
    self.created_by_id = current_user_id if self.created_by_id.blank?
  end

  def mandatory_values_check(attributed)
  end

  def secondary_entity_xor_location
    # if [month_day, week_day, hour].compact.count =! 1 - Can handle more than two attributes
    errors.add(:base, "Secondary Business Entity or Location must be entered") if !(secondary_entity.present? ^ secondary_location.present?)
  end

  def set_primary_entity_based_on_location
    self.primary_entity_id = self.primary_location.business_entity.id
  end

  def consolidate_line_items_on_product
  end

  def set_number
    begin
      self.number = InventoryTxn.where(voucher_sequence_id: self.voucher_sequence_id).maximum(:number).to_i.succ if self.number.blank? || self.number == 0
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
    line_items.sum(:quantity)
  end

  def self.product_details_by_ids(product_ids)
    Product.product_details_by_ids(product_ids)
  end
end
