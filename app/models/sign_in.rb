class SignIn < ActiveType::Object

  attribute :email_id, :varchar
  attribute :password, :varchar
  attribute :remember_me, :boolean

  validates :email_id, presence: true, email: true
  validates :password, presence: true

  before_validation :validate_user_and_other_checks
  after_save :update_counters

  def find_user
    User.active.find_by(email: email_id.downcase) if email_id.present?
  end

  private

  def validate_user_and_other_checks
    if EmailCheck.validate(email_id) && email_id.present? && password.present?
      user = find_user
      if user.blank?
        errors.add(:email_id, 'not associated to any user.')
      else
        validate_password(user)
      end
    end
  end

  def validate_password(user)
    if user.authenticate(password)
      return user
    else
      errors.add(:password, 'incorrect.')
    end
  end

  def update_counters
    user = find_user
    last_signin = user.current_sign_in_at
    user.update(current_sign_in_at: Time.current,
                last_sign_in_at: last_signin,
                sign_in_count: user.sign_in_count.to_i + 1)
  end
end
