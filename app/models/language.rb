class Language < MyActiveRecord
  include Tree

  has_many :products, inverse_of: :language, dependent: :restrict_with_exception

  validates :name, presence: true, length: { in: 3..100 }, uniqueness: { case_sensitive: false }
  validates :active, inclusion: { in: [true, false] }
  # validates :code, presence: true, uniqueness: true, length: { in: 3..3 }

  # before_save :upcase_code

  # def upcase_code
  #   self.code = self.code.upcase if self.code.present?
  # end

  def parent_enum
    Language.where.not(id: id).map { |c| [ c.name, c.id ] }
  end
end
