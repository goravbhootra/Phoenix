namespace :accounts_seed_data do

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
