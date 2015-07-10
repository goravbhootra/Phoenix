class Account::SalesAccount < Account
  self.normal_credit_balance = true
  has_one :location_sales_account, class_name: 'BusinessEntityLocation', inverse_of: :sales_account, dependent: :restrict_with_exception
end
