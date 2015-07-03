class Publisher < MyActiveRecord
  belongs_to :business_entity, inverse_of: :publisher
  has_many :products, inverse_of: :publisher

  validates :business_entity, presence: true, uniqueness: true
  validates :active, inclusion: { in: [true, false] }

  def name
    business_entity.alias_name
  end
end
