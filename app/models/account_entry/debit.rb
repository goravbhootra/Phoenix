class AccountEntry::Debit < AccountEntry
  belongs_to :debit_account_txn, class_name: 'AccountTxn', inverse_of: :debit_entries, touch: true

  attr_accessor :bank_name, :card_last_digits, :expiry_month, :expiry_year, :mobile_number, :card_holder_name

  validates :bank_name, :card_last_digits, :expiry_month, :expiry_year, :mobile_number, :card_holder_name, presence: true, if: :pos_invoice?
  validates :debit_account_txn, presence: true

  def pos_invoice?
    return true if debit_account_txn.type == 'PosInvoice'
    false
  end
end
