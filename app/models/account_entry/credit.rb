class AccountEntry::Credit < AccountEntry
  belongs_to :credit_account_txn, class_name: 'AccountTxn', inverse_of: :credit_entries, touch: true

  validates :credit_account_txn, presence: true
end
