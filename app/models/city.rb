class City < MyActiveRecord
  belongs_to :state, inverse_of: :cities
  belongs_to :zone, inverse_of: :cities
  has_many :business_entities, inverse_of: :city, dependent: :restrict_with_exception
  has_many :users, inverse_of: :city, dependent: :restrict_with_exception

  validates :name, presence: true, length: { in: 3..50 }
  validates :state_id, presence: true, uniqueness: { scope: :name, case_sensitive: false }
  validates :zone_id, presence: true, uniqueness: { scope: :name, case_sensitive: false }
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where active: true, reserved: false }
  scope :unreserved, -> { where reserved: false }

  def city_name
    name
  end
end
