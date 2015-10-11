namespace :state_zone_city do

  desc "States data seeding"
  task seed_states: :environment do
    ActiveRecord::Base.transaction do
        region = Region.create_with(currency_id: 1, active: true).where(name: 'India', code: 'IND').first_or_create
        State.create_with(region: region, active: true, code: 'AN').find_or_create_by(name: "Andaman and Nicobar Islands")
        State.create_with(region: region, active: true, code: 'AP').find_or_create_by(name: "Andhra Pradesh")
        State.create_with(region: region, active: true, code: 'AR').find_or_create_by(name: "Arunachal Pradesh")
        State.create_with(region: region, active: true, code: 'AS').find_or_create_by(name: "Assam")
        State.create_with(region: region, active: true, code: 'BR').find_or_create_by(name: "Bihar")
        State.create_with(region: region, active: true, code: 'CH').find_or_create_by(name: "Chandigarh")
        State.create_with(region: region, active: true, code: 'CT').find_or_create_by(name: "Chhattisgarh")
        State.create_with(region: region, active: true, code: 'DN').find_or_create_by(name: "Dadar and Nagar Haveli")
        State.create_with(region: region, active: true, code: 'DD').find_or_create_by(name: "Daman and Diu")
        State.create_with(region: region, active: true, code: 'DL').find_or_create_by(name: "Delhi")
        State.create_with(region: region, active: true, code: 'GA').find_or_create_by(name: "Goa")
        State.create_with(region: region, active: true, code: 'GJ').find_or_create_by(name: "Gujarat")
        State.create_with(region: region, active: true, code: 'HR').find_or_create_by(name: "Haryana")
        State.create_with(region: region, active: true, code: 'HP').find_or_create_by(name: "Himachal Pradesh")
        State.create_with(region: region, active: true, code: 'JK').find_or_create_by(name: "Jammu & Kashmir")
        State.create_with(region: region, active: true, code: 'JH').find_or_create_by(name: "Jharkhand")
        State.create_with(region: region, active: true, code: 'KA').find_or_create_by(name: "Karnataka")
        State.create_with(region: region, active: true, code: 'KL').find_or_create_by(name: "Kerala")
        State.create_with(region: region, active: true, code: 'LD').find_or_create_by(name: "Lakshadweep")
        State.create_with(region: region, active: true, code: 'MP').find_or_create_by(name: "Madhya Pradesh")
        State.create_with(region: region, active: true, code: 'MH').find_or_create_by(name: "Maharashtra")
        State.create_with(region: region, active: true, code: 'MN').find_or_create_by(name: "Manipur")
        State.create_with(region: region, active: true, code: 'ML').find_or_create_by(name: "Meghalaya")
        State.create_with(region: region, active: true, code: 'MZ').find_or_create_by(name: "Mizoram")
        State.create_with(region: region, active: true, code: 'NL').find_or_create_by(name: "Nagaland")
        State.create_with(region: region, active: true, code: 'OR').find_or_create_by(name: "Odisha")
        State.create_with(region: region, active: true, code: 'PY').find_or_create_by(name: "Puducherry")
        State.create_with(region: region, active: true, code: 'PB').find_or_create_by(name: "Punjab")
        State.create_with(region: region, active: true, code: 'RJ').find_or_create_by(name: "Rajasthan")
        State.create_with(region: region, active: true, code: 'SK').find_or_create_by(name: "Sikkim")
        State.create_with(region: region, active: true, code: 'TN').find_or_create_by(name: "Tamilnadu")
        State.create_with(region: region, active: true, code: 'TG').find_or_create_by(name: "Telangana")
        State.create_with(region: region, active: true, code: 'TR').find_or_create_by(name: "Tripura")
        State.create_with(region: region, active: true, code: 'UP').find_or_create_by(name: "Uttar Pradesh")
        State.create_with(region: region, active: true, code: 'UT').find_or_create_by(name: "Uttarakhand")
        State.create_with(region: region, active: true, code: 'WB').find_or_create_by(name: "West Bengal")
    end
    puts "States data seed successful"
  end

  desc "Zones data seeding"
  task seed_zones: :environment do
    ActiveRecord::Base.transaction do
        region = Region.create_with(currency_id: 1, active: true).where(name: 'India', code: 'IND').first_or_create
        Zone.find_or_create_by(region: region, code: "1A", name: "AP North")
        Zone.find_or_create_by(region: region, code: "1B", name: "AP South")
        Zone.find_or_create_by(region: region, code: "2A", name: "Tamilnadu North")
        Zone.find_or_create_by(region: region, code: "2B", name: "Tamilnadu South")
        Zone.find_or_create_by(region: region, code: "3A", name: "Karnataka North")
        Zone.find_or_create_by(region: region, code: "3B", name: "Karnataka South")
        Zone.find_or_create_by(region: region, code: "4A", name: "Maharashtra West")
        Zone.find_or_create_by(region: region, code: "4B", name: "Maharashtra East")
        Zone.find_or_create_by(region: region, code: "5A", name: "New Delhi")
        Zone.find_or_create_by(region: region, code: "5B", name: "NCR Rest")
        Zone.find_or_create_by(region: region, code: "6A", name: "West Bengal West")
        Zone.find_or_create_by(region: region, code: "6B", name: "West Bengal East")
    end
    puts "Zones data seed successful"
  end

  desc "Cities data seeding"
  task seed_cities: :environment do
    ActiveRecord::Base.transaction do
      City.create_with(zone: Zone.find_by(code: "2A"), state: State.find_by(name: "Tamilnadu"), active: true, branch: true).find_or_create_by(name: "Chennai")
      City.create_with(zone: Zone.find_by(code: "3A"), state: State.find_by(name: "Karnataka"), active: true, branch: true).find_or_create_by(name: "Bangalore")
      City.create_with(zone: Zone.find_by(code: "1A"), state: State.find_by(name: "Andhra Pradesh"), active: true, branch: true).find_or_create_by(name: "Hyderabad")
      City.create_with(zone: Zone.find_by(code: "6A"), state: State.find_by(name: "West Bengal"), active: true, branch: true).find_or_create_by(name: "Kolkata")
      City.create_with(zone: Zone.find_by(code: "4A"), state: State.find_by(name: "Maharashtra"), active: true, branch: true).find_or_create_by(name: "Mumbai")
      City.create_with(zone: Zone.find_by(code: "2B"), state: State.find_by(name: "Tamilnadu"), active: true, branch: true).find_or_create_by(name: "Tirupur")
      City.create_with(zone: Zone.find_by(code: "5A"), state: State.find_by(name: "Delhi"), active: true).find_or_create_by(name: "Delhi")
      City.create_with(zone: Zone.find_by(code: "2B"), state: State.find_by(name: "Tamilnadu"), active: true).find_or_create_by(name: "Madurai")
      City.create_with(zone: Zone.find_by(code: "3B"), state: State.find_by(name: "Karnataka"), active: true).find_or_create_by(name: "Mysore")
      City.create_with(zone: Zone.find_by(code: "4B"), state: State.find_by(name: "Maharashtra"), active: true).find_or_create_by(name: "Nagpur")
      City.create_with(zone: Zone.find_by(code: "4B"), state: State.find_by(name: "Maharashtra"), active: true).find_or_create_by(name: "Pune")
      City.create_with(zone: Zone.find_by(code: "1A"), state: State.find_by(name: "Andhra Pradesh"), active: true).find_or_create_by(name: "Vijayawada")
      City.create_with(zone: Zone.find_by(code: "1B"), state: State.find_by(name: "Andhra Pradesh"), active: true).find_or_create_by(name: "Visakhapatnam")
    end
    puts "Cities data seed successful"
  end

  # desc "Business Entities with users data seeding"
  # task :seed_business_entitites_with_users => :environment do
  #   BusinessEntity.create_with(alias: '',
  #                              city_id: 1, registration_status: 1,
  #                              primary_address: 'Chennai',
  #                              publisher_attributes: {active: true}).where(
  #                              name: '').first_or_create
  #   BusinessEntity.create_with(alias: '',
  #                              city: City.where(name: 'Bangalore').first,
  #                              registration_status: 1,
  #                              primary_address: 'Bangalore').where(
  #                              name: '').first_or_create

  #   1.upto(2) do |business_entity|
  #     BusinessEntityUser.create_with(active: true).where(business_entity_id: business_entity, user_id: 1).first_or_create
  #   end
  # end

  desc "Run all tasks in this file"
  task all: [:seed_states, :seed_zones, :seed_cities]#, :seed_business_entitites_with_users]
end
