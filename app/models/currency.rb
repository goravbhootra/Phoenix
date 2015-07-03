class Currency < MyActiveRecord
  has_many :regions, inverse_of: :currency, dependent: :restrict_with_exception
  has_many :invoices, inverse_of: :currency, dependent: :restrict_with_exception
  has_many :orders, inverse_of: :currency, dependent: :restrict_with_exception

  validates :name, presence: true, length: { in: 3..100 }, uniqueness: { case_sensitive: false }
  validates :code, presence: true, length: { in: 1..3 }, uniqueness: { case_sensitive: false }
  validates :active, inclusion: { in: [true, false] }

  before_validation lambda { self.code = self.code.upcase if self.code.present? }

  default_scope -> { where reserved: false }
end
