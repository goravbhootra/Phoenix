class BusinessEntityLocation < MyActiveRecord
  belongs_to :business_entity, inverse_of: :locations
  belongs_to :user_role, inverse_of: :business_entity_locations
  has_many :inventory_vouchers, inverse_of: :business_entity_location, dependent: :restrict_with_exception
  has_many :receiving_inventory_vouchers, class_name: 'InventoryVoucher', inverse_of: :receiving_business_entity_location, dependent: :restrict_with_exception
  has_many :inventory_txns, class_name: 'InventoryTxn', foreign_key: 'primary_location_id', inverse_of: :primary_location, dependent: :restrict_with_exception
  has_many :secondary_inventory_txns, class_name: 'InventoryTxn', foreign_key: 'primary_location_id', inverse_of: :secondary_location, dependent: :restrict_with_exception
  has_many :invoices, class_name: 'Invoice', foreign_key: 'primary_location_id',
            inverse_of: :primary_location, dependent: :restrict_with_exception
  has_many :user_roles, inverse_of: :business_entity_location, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :business_entity, presence: true, uniqueness: { scope: :name, case_sensitive: false }
  # validates :default, inclusion: { in: [true, false] }
  validates :active, inclusion: { in: [true, false] }

  # bitmask :status, :as => [:storage, :sales], null: false

  delegate :alias_name, to: :business_entity, prefix: true

  scope :active, -> { where active: true }
  scope :own_locations, -> { joins(:business_entity).where(business_entities: {classification: 1}).references(:business_entity) }

  def self.active_n_current(current_record_id=nil)
    where("business_entity_locations.id IN (?)", (active.pluck(:id)+[current_record_id.to_i]-[0]).uniq)
  end

  def self.create_default_location
    { name: 'Main Location', default: true, active: true, position: 1 }
  end

  def entity_name_with_location
    "#{business_entity_alias_name} :: #{name}"
  end
end
