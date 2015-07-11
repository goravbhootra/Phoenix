class AccountTxn < MyActiveRecord
  belongs_to :business_entity, inverse_of: :account_txns
  belongs_to :currency, inverse_of: :account_txns
  belongs_to :voucher_sequence, inverse_of: :account_txns
  belongs_to :created_by, class_name: 'User', inverse_of: :account_txns
  has_many :line_items, class_name: 'AccountTxnLineItem', inverse_of: :account_txn, dependent: :restrict_with_exception, autosave: true
  has_many :entries, class_name: 'AccountEntry', inverse_of: :account_txn, dependent: :restrict_with_exception, autosave: true
  has_many :debit_entries, extend: AccountEntriesExtension, class_name: 'AccountEntry::Debit', inverse_of: :debit_account_txn, dependent: :restrict_with_exception, autosave: true
  has_many :credit_entries, extend: AccountEntriesExtension, class_name: 'AccountEntry::Credit', inverse_of: :credit_account_txn, dependent: :restrict_with_exception, autosave: true
  has_one :invoice_header, inverse_of: :account_txn, dependent: :restrict_with_exception, autosave: true

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

  before_validation :convert_quantity_to_negative
  before_validation :create_sales_entry

  accepts_nested_attributes_for :invoice_header
  accepts_nested_attributes_for :line_items
  accepts_nested_attributes_for :debit_entries
  accepts_nested_attributes_for :credit_entries
  alias_method :credits=, :credit_entries_attributes=
  alias_method :debits=, :debit_entries_attributes=

  enum status: { 'Active': 1, 'Cancelled': 2, 'Approval Required': 3 }

  attr_accessor :current_user_id, :current_location

  scope :active, -> { where status: true }

  def cancelled?
    return true if status == 2
    false
  end

  def create_sales_entry
  end

  def convert_quantity_to_negative
  end

  def has_credit_entries?
    errors[:base] << "Transaction must have at least one valid credit entry" if self.credit_entries.blank? || credit_entries.balance <= 0
  end

  def has_debit_entries?
    errors[:base] << "Transaction must have at least one valid debit entry" if self.debit_entries.blank? || debit_entries.balance <= 0
  end

  def entries_cancel?
    errors[:base] << "The credit and debit entries are not equal" if credit_entries.balance != debit_entries.balance
  end
end
