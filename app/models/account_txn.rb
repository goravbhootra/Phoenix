class AccountTxn < MyActiveRecord
  belongs_to :business_entity, inverse_of: :account_txns
  belongs_to :currency, inverse_of: :account_txns
  belongs_to :voucher_sequence, inverse_of: :account_txns
  belongs_to :created_by, class_name: 'User', inverse_of: :account_txns
  has_many :entries, class_name: 'AccountEntry', extend: AccountEntriesExtension, inverse_of: :account_txn, dependent: :restrict_with_exception, autosave: true
  has_many :debit_entries, class_name: 'AccountEntry::Debit', extend: AccountEntriesExtension, inverse_of: :debit_account_txn, dependent: :restrict_with_exception, autosave: true
  has_many :credit_entries, class_name: 'AccountEntry::Credit', extend: AccountEntriesExtension, inverse_of: :credit_account_txn, dependent: :restrict_with_exception, autosave: true
  has_one :header, class_name: 'InvoiceHeader', inverse_of: :account_txn, dependent: :restrict_with_exception, autosave: true

  validates :business_entity, presence: true
  validates :currency, :voucher_sequence_id, :created_by, presence: true
  validates :type, presence: true
  validates :number_prefix, length: { maximum: 8 }
  validates :number, presence: true, numericality: true, uniqueness: { scope: [:business_entity_id, :number_prefix], case_sensitive: false }
  validates :txn_date, presence: true
  validates :status, presence: true
  validates :ref_number, length: { maximum: 30 }
  validate :has_credit_entries?, unless: :cancelled?
  validate :has_debit_entries?, unless: :cancelled?
  validate :entries_cancel?, unless: :cancelled?

  before_validation :set_voucher_sequence

  accepts_nested_attributes_for :debit_entries
  accepts_nested_attributes_for :credit_entries
  alias_method :credits=, :credit_entries_attributes=
  alias_method :debits=, :debit_entries_attributes=

  enum status: { 'Active': 1, 'Cancelled': 2, 'Approval Required': 3 }

  attr_accessor :current_user_id, :current_location

  scope :active, -> { where status: true }

  def set_voucher_sequence
    self.voucher_sequence_id = self.voucher_sequence_id.presence || VoucherSequence.find_by(business_entity_id: current_business_entity.id, classification: 1).id
  end

  def cancelled?
    return true if status == 'Cancelled' || status == 2
    false
  end

  def has_credit_entries?
    errors[:base] << "Transaction must have at least one valid credit entry" if self.credit_entries.blank? || credit_entries.total_amount <= 0
  end

  def has_debit_entries?
    errors[:base] << "Transaction must have at least one valid debit entry" if self.debit_entries.blank? || debit_entries.total_amount <= 0
  end

  def entries_cancel?
    errors[:base] << "The credit and debit entries are not equal" if credit_entries.total_amount != debit_entries.total_amount
  end
end
