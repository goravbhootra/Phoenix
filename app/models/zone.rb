class Zone < MyActiveRecord
  belongs_to :region, inverse_of: :zones
  has_many :cities, inverse_of: :zone, dependent: :restrict_with_exception

  validates :name, presence: true, length: { in: 3..50 }
  validates :code, presence: true, length: { in: 1..3 }, uniqueness: { case_sensitive: false }
  validates :region_id, presence: true, uniqueness: { scope: :name, case_sensitive: false }
  validates :active, inclusion: { in: [true, false] }

  before_validation lambda { self.code = self.code.upcase if self.code.present? }

  scope :active, -> { where active: true, reserved: false }
  scope :unreserved, -> { where reserved: false }
end
