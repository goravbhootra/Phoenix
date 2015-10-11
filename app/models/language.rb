class Language < MyActiveRecord
  include Tree

  has_many :products, inverse_of: :language, dependent: :restrict_with_exception

  validates :name, presence: true, length: { in: 3..100 }, uniqueness: { case_sensitive: false }
  validates :active, inclusion: { in: [true, false] }

  def parent_enum
    Language.where.not(id: id).map { |c| [ c.name, c.id ] }
  end
end
