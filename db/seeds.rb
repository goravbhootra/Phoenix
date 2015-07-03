# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
Rake::Task['master_tables:seed_all'].invoke
Rake::Task['state_zone_city:seed_all'].invoke
Rake::Task['language_city:seed_all'].invoke
Rake::Task['publication_product_groups:seed_all'].invoke
