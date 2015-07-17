class AccountEntry::Debit < AccountEntry
  belongs_to :debit_account_txn, class_name: 'AccountTxn', inverse_of: :debit_entries, touch: true

  attr_accessor :bank_name, :card_last_digits, :expiry_month, :expiry_year, :mobile_number, :card_holder_name#, :mode

  validates :debit_account_txn, presence: true

  # def pos_invoice?
  #   return true if debit_account_txn.type && debit_account_txn.type == 'PosInvoice'
  #   false
  # end
end
