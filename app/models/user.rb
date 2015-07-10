class User < MyActiveRecord
  has_secure_password

  belongs_to :city, inverse_of: :users
  has_many :business_entity_users, dependent: :restrict_with_exception, inverse_of: :user
  has_many :business_entities, through: :business_entity_users
  has_many :booked_orders, class_name: 'Order', foreign_key: 'booked_by_id', inverse_of: :booked_by, dependent: :restrict_with_exception
  has_many :created_invoices, class_name: 'Invoice', foreign_key: 'created_by_id', inverse_of: :created_by, dependent: :restrict_with_exception
  has_many :created_inventory_txns, class_name: 'InventoryTxn', foreign_key: 'created_by_id', inverse_of: :created_by, dependent: :restrict_with_exception
  has_many :received_payments, class_name: 'InvoicePayment', foreign_key: 'received_by_id', inverse_of: :received_by, dependent: :restrict_with_exception
  has_many :created_inventory_vouchers, class_name: 'InventoryVoucher', foreign_key: 'created_by_id', inverse_of: :created_by, dependent: :restrict_with_exception
  has_many :account_txns, class_name: 'AccountTxn', foreign_key: 'created_by_id', inverse_of: :created_by, dependent: :restrict_with_exception
  has_many :user_roles, autosave: true, dependent: :destroy, inverse_of: :user
  has_many :roles, through: :user_roles


  validates :name, presence: true, length: { in: 3..100 }
  validates :membership_number, presence: true, uniqueness: true, length: { is: 9 }
  validates :city, presence: true
  validates :email, presence: true, email: true, length: { in: 6..100 }, uniqueness: { case_sensitive: false}
  validates :password, confirmation: true,
            length: 6..70, allow_blank: { on: :update }, presence: { on: :create }
  validates :contact_number_primary, :contact_number_secondary, length: { in: 8..15 },
            allow_nil: true, allow_blank: true
  validates :active, inclusion: { in: [true, false] }

  before_validation :set_password
  # before_create :check_role_presence
  before_create { generate_token(:auth_token) }
  before_validation :downcase_email

  default_scope -> { where reserved: false }
  scope :active, -> { where active: true }

  delegate :name, to: :city, prefix: true, allow_nil: true

  def downcase_email
    self.email = self.email.downcase if self.email.present?
  end

  def role?(role=nil)
    roles.where(name: role).exists?
  end

  # def check_role_presence
  #   roles << :user if roles.blank?
  # end

  def self.reset_auth_token
    digest(new_auth_token)
  end

  # def user_city
  #   city_name
  # end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def self.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def set_password
    if self.new_record?
      self.password = 'changeME'
      self.password_confirmation = 'changeME'
    end
  end

  def self.new_auth_token
    SecureRandom.urlsafe_base64
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver_now!
  end

  def send_email_confirmation_request
    if !self.is_confirmed?
      generate_token(:email_confirmation_token)
      self.email_confirmation_sent_at = Time.zone.now
      save!
      UserMailer.email_confirmation_request(self).deliver_now!
    end
  end

  ############# to be deleted after migration ##############
  bitmask :old_roles, as: [:user, :admin, :power_user, :pos_manager], null: false
  # user.roles = [:publisher, :editor]
  # user.roles << :admin
  def admin?
    (self.old_roles & [:admin]).present?
  end

  def power_user?
    (self.old_roles & [:power_user]).present?
  end

  def pos_manager?
    (self.old_roles & [:pos_manager]).present?
  end
  ############# end to be deleted after migration ##############
end
