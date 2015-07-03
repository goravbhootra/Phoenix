class State < MyActiveRecord
  belongs_to :region, inverse_of: :states
  has_many :cities, inverse_of: :state, dependent: :restrict_with_exception
  has_many :state_category_tax_rates, inverse_of: :state, dependent: :restrict_with_exception

  validates :name, presence: true, length: { in: 3..50 }
  validates :code, presence: true, length: { in: 1..3 }, uniqueness: { case_sensitive: false }
  validates :region_id, presence: true, uniqueness: { scope: :name, case_sensitive: false }
  validates :active, inclusion: { in: [true, false] }

  before_validation :code_upcase

  delegate :name, to: :region, prefix: true, allow_nil: true

  default_scope -> { where reserved: false }

  def code_upcase
    self.code = self.code.upcase if self.code.present?
  end
end
