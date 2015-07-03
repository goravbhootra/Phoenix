namespace :accounts_seed_data do

  # desc "Account Types seeding"
  # task :seed_account_types do
  #   # added enum normal_balance_enum: { 'debit': 1, 'credit': 2 } in account_type.rb
  #   AccountType.create!([
  #     { name: 'CurrentAsset', title: 'Current Assets', normal_balance: 'debit' },
  #     { name: 'CurrentLiability', title: 'Current Liabilities', normal_balance: 'credit' },
  #     { name: 'FixedAsset', title: 'Fixed Assets', normal_balance: 'debit' },
  #     { name: 'SalesAccount', title: 'Sales Accounts', normal_balance: 'debit' },
  #     { name: 'PurchaseAccount', title: 'Purchase Accounts', normal_balance: 'credit' },
  #     { name: 'DirectExpense', title: 'Direct Expenses', normal_balance: 'debit' },
  #     { name: 'IndirectExpense', title: 'Indirect Expenses', normal_balance: 'debit' },
  #     { name: 'Investment',  title: 'Investments',,normal_balance: 'debit' },
  #     { name: 'LoansLiability', title: 'Loans (Liability)', normal_balance: 'credit '}
  #   ])

  #   current_assets = AccountType.find_by_name('Current Assets')
  #   current_liabilities = AccountType.find_by_name('Current Liabilities')
  #   AccountType.create!([
  #     { name: 'BankAccount', title: 'Bank Accounts', parent: current_assets,
  #       normal_balance: 'debit' },
  #     { name: 'CashInHand', title: 'Cash-in-hand', parent: current_assets,
  #       normal_balance: 'debit' },
  #     { name: 'LoansAdvancesAsset', title: 'Loans & Advances (Asset)', parent: current_assets,
  #       normal_balance: 'debit' },
  #     { name: 'SundryDebtor', title: 'Sundry Debtors', parent: current_assets,
  #       normal_balance: 'debit' },
  #     { name: 'SundryCreditor', title: 'Sundry Creditors', parent: current_liabilities,
  #       normal_balance: 'credit' },
  #     { name: 'DutiesTax', title: 'Duties & Taxes', parent: current_liabilities,
  #       normal_balance: 'credit' },
  #     { name: 'Provision', title: 'Provisions', parent: current_liabilities,
  #       normal_balance: 'credit' }
  #   ])
  # end

  desc "Accounts seeding"
  task :seed_accounts do
    BusinessEntity.find_each do |entity|
      SaleAccount.create!([
        { business_entity: entity, name: 'Sales' }
      ])

      BankAccount.create!([
        { business_entity: entity, name: 'Bank' }
      ])

      CashInHand.create!([
        { business_entity: entity, name: 'Cash' }
      ])

      DutiesTax.create!([
        { business_entity: entity, name: 'sales Tax' }
      ])
    end
  end
end
