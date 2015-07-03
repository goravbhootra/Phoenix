class Region < MyActiveRecord
  belongs_to :currency, inverse_of: :regions
  has_many :states, inverse_of: :region, dependent: :restrict_with_exception
  has_many :zones, inverse_of: :region, dependent: :restrict_with_exception

  validates :name, presence: true, length: { in: 3..50 }, uniqueness: { case_sensitive: false }
  validates :code, presence: true, length: { in: 1..3 }, uniqueness: { case_sensitive: false }
  validates :currency_id, presence: true
  validates :active, inclusion: { in: [true, false] }

  before_validation lambda { self.code = self.code.upcase if self.code.present? }

  default_scope -> { where reserved: false }
end
