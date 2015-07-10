class Account::CashAccount < Account::CurrentAsset
  has_one :location_cash_account, class_name: 'BusinessEntityLocation', inverse_of: :cash_account, dependent: :restrict_with_exception
end
