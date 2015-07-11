class StateCategoryTaxRate < MyActiveRecord
  belongs_to :state, inverse_of: :state_category_tax_rates
  belongs_to :category, -> { where category_id: Category.roots.pluck(:id) }, inverse_of: :state_category_tax_rates
  has_many :account_txn_line_items, inverse_of: :state_category_tax_rate, dependent: :restrict_with_exception

  validates :state_id, presence: true
  validates :category_id, presence: true
  validates :interstate_rate, :intrastate_rate, presence: true
  validates :interstate_label, :intrastate_label, presence: true, length: { in: 1..10 }
  validates :valid_from, presence: true, uniqueness: { scope: [:state_id, :category_id] }
  validates :classification, presence: true
  validates :active, inclusion: { in: [true, false] }

  def classification_enum
    { 'Sale': 1, 'Purchase': 2 }
  end

  def category_enum
    Category.roots.pluck(:name, :id)
  end
end
