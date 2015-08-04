class BusinessEntityUser < MyActiveRecord
  belongs_to :business_entity, inverse_of: :business_entity_users
  belongs_to :user, inverse_of: :business_entity_users

  validates :business_entity, presence: true
  validates :user, presence: true, uniqueness: { scope: :business_entity }
  validates :active, inclusion: { in: [true, false] }
  validates :designation, length: { maximum: 30 }, allow_nil: true, allow_blank: true

  def name
    user.name
  end
end
