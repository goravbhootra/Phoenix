class Role < MyActiveRecord
  has_many :user_roles, autosave: true, dependent: :destroy, inverse_of: :role
  has_many :users, through: :user_roles

  validates :name, presence: true, length: { in: 3..40 }, uniqueness: { case_sensitive: false }
  validates :mail_enabled, inclusion: { in: [true, false] }
  validates :active, inclusion: { in: [true, false] }
end
