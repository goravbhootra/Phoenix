class InventoryVoucher < MyActiveRecord
  belongs_to :business_entity, inverse_of: :inventory_vouchers
  belongs_to :receiving_business_entity, class_name: 'BusinessEntity', inverse_of: :receiving_inventory_vouchers
  belongs_to :voucher_sequence, inverse_of: :inventory_vouchers
  belongs_to :created_by, class_name: 'User', inverse_of: :created_inventory_vouchers
  belongs_to :currency, inverse_of: :inventory_txns
  belongs_to :business_entity_location, inverse_of: :inventory_vouchers
  belongs_to :receiving_business_entity_location, class_name: 'BusinessEntityLocation', inverse_of: :receiving_inventory_vouchers
  has_many :line_items, class_name: 'InventoryVoucherLineItem', dependent: :destroy, inverse_of: :inventory_voucher, autosave: true

  # validates :business_entity, presence: true # validation disabled as input is received clubbed with entity_business_entity_location
  validates :business_entity_location, presence: true
  validates :receiving_business_entity_location, presence: true#, if: :two_locations_involved?
  # validates :receiving_business_entity_location, absence: true, unless: :two_locations_involved?
  validates :voucher_sequence, presence: true
  validates :created_by, presence: true
  validates :currency, presence: true
  validates :total_amount, presence: true, numericality: { less_than_or_equal_to: 99999999 }
  validates :voucher_date, presence: true
  validates :number, presence: true
  validates :ref_number, length: { maximum: 30 }
  validates :number_prefix, length: { maximum: 8 }

  accepts_nested_attributes_for :line_items,allow_destroy: true, reject_if: :missed_mandatory_values

  before_validation :consolidate_line_items
  before_validation :consolidate_line_items_on_product
  before_validation :process_calculations
  before_validation :set_defaults

  before_create :set_number
  before_save :set_business_entity
  before_save :store_quantity_as_negative
  # before_save :process_calculations

  enum status: { 'Active': 1, 'Draft': 2, 'Deleted': 3, 'Waiting Approval': 4 }
  # enum classification: { opening_stock: 1, intra_business_entity_transfer: 2,
  #                         corpus_distribution: 4, gratis_distribution: 5 }

  scope :created_by_user, -> (user_id) { where(created_by_id: user_id) }

  delegate :name, to: :created_by, prefix: true, allow_nil: true
  delegate :entity_name_with_location, to: :business_entity_location, prefix: 'primary', allow_nil: true

  attr_accessor :current_user_id

  def initialize(attributes={})
    super
    self.currency_id = attributes[:currency_id].presence || 1 # Default INR
    self.status = attributes[:status].presence || 1 # Default Active
    self.number = attributes[:number].presence || 0 # Pre-filled for new invoice
  end

  def set_defaults
    self.created_by_id = self.created_by_id.presence || current_user_id
    self.voucher_sequence_id = self.voucher_sequence_id.presence || 2
  end

  def missed_mandatory_values(attributed)
    # handle new records with invalid data
    return true if attributed['id'].blank? && (attributed['product_id'].blank? || attributed['quantity'].to_i < 1)
    # handle existing records with invalid data
    attributed['_destroy'] = true if attributed['id'].present? && (attributed['product_id'].blank? || attributed['quantity'].to_i < 1)
  end

  def consolidate_line_items_on_product
    VoucherConsolidateLineItems.new({voucher: self, association_name: 'line_items', attrib_id: 'product_id', consolidate: 'quantity'}).consolidate_with_same_attribute
  end

  # def two_locations_involved?
  #   return true if self.classification == 'intra_business_entity_transfer' || self.classification == 'inter_business_entity_transfer'
  #   false
  # end

  def set_business_entity
    self.business_entity_id = self.business_entity_location.business_entity_id if self.business_entity_id.blank?
  end

  def set_number
    begin
      self.number = InventoryVoucher.maximum(:number).to_i.succ if self.number.blank? || self.number == 0
      self.number_prefix = self.voucher_sequence.number_prefix
    rescue => e
      Airbrake.notify(e)
      errors.add(:base, 'Could not obtain Adjustment voucher number. Please retry saving.') and return false
    end
  end

  def consolidate_line_items
    VoucherConsolidateLineItems.new({voucher: self, association_name: 'line_items', attrib_id: 'product_id', consolidate: 'quantity'}).consolidate_with_same_attribute
  end

  def process_calculations
    VoucherCalculations.new({voucher: self, quantity_field: 'quantity'}).process_totals
  end

  def voucher_number
    prefix = number_prefix.presence || ''
    "#{prefix}#{number.to_s.rjust(4, '0')}"
  end

  def store_quantity_as_negative
    self.line_items.each { |x| x.quantity = -x.quantity if x.quantity > 0} #if %w(intra_business_entity_transfer corpus_distribution gratis_distribution).include?(self.classification)
  end
end
