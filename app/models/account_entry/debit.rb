class AccountEntry::Debit < AccountEntry
  belongs_to :debit_account_txn, class_name: 'AccountTxn', inverse_of: :debit_entries, touch: true

  attr_accessor :bank_name, :card_last_digits, :expiry_month, :expiry_year, :mobile_number, :card_holder_name

  validates :debit_account_txn, presence: true
  validates :bank_name, presence: true, if: :pos_invoice_with_credit_card_payment?
  validates :card_last_digits, length: { is: 4 }, numericality: { only_integer: true }, presence: true, if: :pos_invoice_with_credit_card_payment?
  validates :expiry_month, presence: true, if: :pos_invoice_with_credit_card_payment?
  validates :expiry_year, numericality: { only_integer: true, greater_than_or_equal_to: 2015, less_than_or_equal_to: 2050 }, presence: true, if: :pos_invoice_with_credit_card_payment?
  validates :mobile_number, numericality: { greater_than_or_equal_to: 999999999, less_than_or_equal_to: 9999999999 }, presence: true, if: :pos_invoice_with_credit_card_payment?
  validates :card_holder_name, presence: true, if: :pos_invoice_with_credit_card_payment?

  before_validation :populate_credit_card_information

  def pos_invoice_with_credit_card_payment?
    return true if debit_account_txn.type && debit_account_txn.type == 'PosInvoice'
    false
  end

  def populate_credit_card_information
    if pos_invoice_with_credit_card_payment?
      additional_info ||= Hash.new
      additional_info['bank_name'] = self.bank_name
      additional_info['card_last_digits'] = self.card_last_digits
      additional_info['expiry_month'] = self.expiry_month
      additional_info['expiry_year'] = self.expiry_year
      additional_info['mobile_number'] = self.mobile_number
      additional_info['card_holder_name'] = self.card_holder_name
    end
  end
end
