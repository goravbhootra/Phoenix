class Account < MyActiveRecord
  belongs_to :business_entity, inverse_of: :accounts

  validates :business_entity, presence: true
  validates :name, presence: true, length: { in: 3..100 }, uniqueness: {scope: :business_entity}
  validates :alias_name, length: { in: 3..25 }, presence: true, uniqueness: { scope: :business_entity }
  # validates :code, length: { is: 6 }, presence: true, uniqueness: {scope: :business_entity}
  validates :type, presence: true
  validates :contra, inclusion: { in: [true, false] }
  validates :reserved, inclusion: { in: [true, false] }
  validates :active, inclusion: { in: [true, false] }

  class_attribute :normal_credit_balance
end
