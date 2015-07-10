class Account::BankAccount < Account::CurrentAsset
  has_one :location_bank_account, class_name: 'BusinessEntityLocation', inverse_of: :bank_account, dependent: :restrict_with_exception
end
