class Uom < MyActiveRecord
  has_many :products, inverse_of: :uom, dependent: :restrict_with_exception

  validates :name, presence: true, length: { in: 3..100 }, uniqueness: { case_sensitive: false }
  validates :print_name, presence: true, length: { in: 1..5 }, uniqueness: { case_sensitive: false }
  validates :active, inclusion: { in: [true, false] }

  def association_display
    print_name
  end
end
