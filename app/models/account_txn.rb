class AccountTxn < MyActiveRecord
  belongs_to :business_entity, inverse_of: :account_txns
  belongs_to :currency, inverse_of: :account_txns
  belongs_to :voucher_sequence, inverse_of: :account_txns
  belongs_to :created_by, class_name: 'User', inverse_of: :account_txns
  has_many :entries, class_name: 'AccountEntry', extend: AccountEntriesExtension, inverse_of: :account_txn, dependent: :restrict_with_exception, autosave: true
  has_many :debit_entries, class_name: 'AccountEntry::Debit', extend: AccountEntriesExtension, inverse_of: :debit_account_txn, dependent: :restrict_with_exception, autosave: true
  has_many :credit_entries, class_name: 'AccountEntry::Credit', extend: AccountEntriesExtension, inverse_of: :credit_account_txn, dependent: :restrict_with_exception, autosave: true
  has_one :header, class_name: 'InvoiceHeader', inverse_of: :account_txn, dependent: :restrict_with_exception, autosave: true
  has_many :line_items, class_name: 'InvoiceLineItem', extend: InvoiceLineItemsExtension, foreign_key: 'account_txn_id', inverse_of: :account_txn, dependent: :restrict_with_exception, autosave: true

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

  before_validation :set_defaults
  before_validation :set_voucher_sequence

  before_create :set_number

  accepts_nested_attributes_for :debit_entries, allow_destroy: true, reject_if: :payment_mandatory_values_check
  accepts_nested_attributes_for :credit_entries, allow_destroy: true, reject_if: :payment_mandatory_values_check

  enum status: { 'Active': 1, 'Cancelled': 2, 'Approval Required': 3 }

  attr_accessor :current_user_id, :current_location, :current_business_entity

  scope :active, -> { where status: true }

  def initialize(attributes={})
    super
    self.status = attributes[:status].presence || 1 # Default Active
    self.number = attributes[:number].presence || 0 # Pre-filled for new invoice
    self.business_entity_id = 1 if self.business_entity_id.blank?
    self.voucher_sequence_id = 6 if self.voucher_sequence_id.blank?
    self.currency_id = 1 if self.currency_id.blank?
  end

  def set_voucher_sequence
    self.voucher_sequence_id = self.voucher_sequence_id.presence || VoucherSequence.find_by(business_entity_id: 1, classification: 1).id
  end

  def set_defaults
    self.created_by_id = current_user_id if self.created_by_id.blank?
  end

  def set_number
    begin
      self.number = AccountTxn.where(voucher_sequence_id: self.voucher_sequence_id).maximum(:number).to_i.succ if self.number.blank? || self.number == 0
      self.number_prefix = self.voucher_sequence.number_prefix
    rescue => e
      Airbrake.notify(e)
      errors.add(:base, 'Could not obtain invoice number. Please retry saving.') and return false
    end
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

  def payment_mandatory_values_check(attributed)
    if attributed['account_id'].blank? || attributed['amount'].to_i < 1
      # handle new records with invalid data
      return true if attributed['id'].blank?

      # handle existing records with invalid data
      attributed['_destroy'] = true if attributed['id'].present?
    end
    false
  end

  def voucher_number
    prefix = number_prefix.presence || ''
    "#{prefix}#{number.to_s.rjust(5, '0')}"
  end
end
