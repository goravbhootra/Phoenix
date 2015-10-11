class UserRole < MyActiveRecord
  belongs_to :user, inverse_of: :user_roles, touch: true
  belongs_to :role, inverse_of: :user_roles, touch: true
  belongs_to :business_entity, inverse_of: :user_roles
  belongs_to :business_entity_location, inverse_of: :user_roles

  validates :user, :role, presence: true
  validate  :business_entity_xor_location_xor_global
  validates :global, inclusion: { in: [true, false] }
  validates :active, inclusion: { in: [true, false] }

  def business_entity_xor_location_xor_global
    # if [month_day, week_day, hour].compact.count =! 1 - Can handle more than two attributes
    errors.add(:base, "Business Entity or Location or Global must be entered/checked") if !((business_entity.present? ^ business_entity_location.present?) ^ global)
  end
end
