namespace :accounts_seed_data do

  desc "Accounts seeding"
  task :seed_accounts do
    BusinessEntity.create_with(alias_name: 'Solutionize', city_id: 1, registration_status: 1, primary_address: 'Manapakkam, Chennai, India').where(name: 'Solutionize Tech Labs LLP').first_or_create!
    puts 'BusinessEntity seed successful'

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
