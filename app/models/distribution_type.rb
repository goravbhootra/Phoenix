class DistributionType < MyActiveRecord
  has_many :products, inverse_of: :distribution_type, dependent: :restrict_with_exception

  validates :name, presence: true, length: { in: 3..100 }, uniqueness: { case_sensitive: false }
  validates :active, inclusion: { in: [true, false] }
end
