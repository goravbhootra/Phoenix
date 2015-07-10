class AccountEntry::Debit < AccountEntry
  belongs_to :debit_account_txn, class_name: 'AccountTxn', inverse_of: :debit_entries, touch: true
end
