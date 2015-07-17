class Category < MyActiveRecord
  include Tree

  has_many :products, inverse_of: :category, dependent: :restrict_with_exception
  has_many :state_category_tax_rates, inverse_of: :category, dependent: :restrict_with_exception

  validates :name, presence: true, length: { in: 3..100 }, uniqueness: { case_sensitive: false }
  validates :active, inclusion: { in: [true, false] }
  # validates :code, presence: true, uniqueness: true, length: { in: 3..3 }

  accepts_nested_attributes_for :state_category_tax_rates

  # before_save :upcase_code

  # def upcase_code
  #   self.code = self.code.upcase if self.code.present?
  # end

  def parent_enum
    # Category.where.not(id: id).map { |c| [ c.name, c.id ] }
    Category.where.not(id: id).pluck(:name, :id)
  end

  def parent_code
    parent.code
  end

  def root_node_name
    root? ? name : parent.name
  end
end
