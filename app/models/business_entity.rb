class BusinessEntity < MyActiveRecord
  belongs_to :city, inverse_of: :business_entities
  has_many :locations, class_name: 'BusinessEntityLocation', inverse_of: :business_entity, dependent: :restrict_with_exception
  has_many :business_entity_users, inverse_of: :business_entity, dependent: :restrict_with_exception
  has_many :users, through: :business_entity_users
  has_many :inventory_txns, foreign_key: 'primary_entity_id', inverse_of: :primary_entity, dependent: :restrict_with_exception
  has_many :secondary_inventory_txns, class_name: 'InventoryTxn', foreign_key: 'secondary_entity_id', inverse_of: :secondary_entity, dependent: :restrict_with_exception
  # has_many :inventory_vouchers, inverse_of: :business_entity, dependent: :restrict_with_exception
  # has_many :receiving_inventory_vouchers, class_name: 'InventoryVoucher', inverse_of: :receiving_business_entity, dependent: :restrict_with_exception
  has_many :voucher_sequences, inverse_of: :business_entity, dependent: :restrict_with_exception
  has_many :invoices, class_name: 'Invoice', inverse_of: :secondary_entity,
            dependent: :restrict_with_exception
  has_many :accounts, inverse_of: :business_entity, dependent: :restrict_with_exception
  has_many :account_txns, inverse_of: :business_entity, dependent: :restrict_with_exception
  has_many :user_roles, inverse_of: :business_entity, dependent: :restrict_with_exception
  has_one :publisher, inverse_of: :business_entity, dependent: :restrict_with_exception

  accepts_nested_attributes_for :business_entity_users, :publisher
  accepts_nested_attributes_for :locations

  validates :name, presence: true, length: { in: 3..200 }
  validates :alias_name, length: { maximum: 40 }, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }
  validates :city, presence: true, uniqueness: { scope: :name }
  validates :registration_status, :classification, presence: true
  validates :email, email: true, length: { in: 6..150 }, allow_nil: true, allow_blank: true
  validates :primary_address, presence: true
  validates :contact_number_primary, :contact_number_secondary, length: { in: 8..15 },
            allow_nil: true, allow_blank: true

  before_validation :strip_strings
  before_create :ensure_default_location_is_created

  scope :unreserved, -> { where reserved: false }
  scope :reverved_and_active, -> { where reserved: true, active: true }
  scope :active, -> { where active: true, reserved: false }
  scope :active_with_reserved, -> { where active: true }
  scope :anc_with_reserved_inventory_out_vouchers, -> (business_entity_id=nil) { active_n_current_with_reserved(business_entity_id).where classification: 1 }
  scope :anc_with_reserved_inventory_in_vouchers, -> (business_entity_id=nil) { active_n_current_with_reserved(business_entity_id).where classification: 2 }

  def self.active_n_current(current_record_id=nil)
    where("id IN (?)", (active.pluck(:id)+[current_record_id.to_i]-[0]).uniq)
  end

  def self.active_n_current_with_reserved(current_record_id=nil)
    where("id IN (?)", (active_with_reserved.pluck(:id)+[current_record_id.to_i]-[0]).uniq)
  end

  def strip_strings
    name = name.strip if name
    alias_name = alias_name.strip if alias_name
  end

  # enum registration_status: { registered_branch: 1,
  #                             additional_place_of_business: 2,
  #                             registered_company: 3,
  #                             unregistered_company: 4,
  #                             registered_individual: 5,
  #                             unregistered_individual: 6 }

  def classification_enum
    {
      'Own Entity': 1,
      'Vendors': 2,
      'Cash': 3,
      'Virtual': 10
    }
  end

  def registration_status_enum
    { 'Registered Branch': 1,
      'Additional Place of Business': 2,
      'Registered Company': 3,
      'Unregistered Company': 4,
      'Registered Individual': 5,
      'Unregistered Individual': 6,
      'Virtual': 10 }
  end

  def ensure_default_location_is_created
    self.attributes[:locations] || self.locations.build(BusinessEntityLocation.create_default_location) if self.classification == 1
  end
end
