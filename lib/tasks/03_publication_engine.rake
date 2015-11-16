namespace :language_city do

	desc "Languages data seeding"
  task :seed_languages => :environment do
		ActiveRecord::Base.transaction do
			ind_lang = Language.create_with(active: true, code: 'Ind').where(name: "Indian").first_or_create
			Language.create_with(parent: ind_lang, active: true, code: 'Eng').where(name: "English").first_or_create
			Language.create_with(parent: ind_lang, active: true, code: 'Hin').where(name: "Hindi").first_or_create
			Language.create_with(parent: ind_lang, active: true, code: 'Tam').where(name: "Tamil").first_or_create
			Language.create_with(parent: ind_lang, active: true, code: 'Tel').where(name: "Telugu").first_or_create
			Language.create_with(parent: ind_lang, active: true, code: 'Kan').where(name: "Kannada").first_or_create
			Language.create_with(parent: ind_lang, active: true, code: 'Mar').where(name: "Marathi").first_or_create

      # Code needs to be added to following languages for seeding them
   #    os_lang = Language.create_with(active: true).where(name: "Non_Indian").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Afrikaans").first_or_create
			# Language.create_with(parent: os_lang, active: true).where(name: "Chinese").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Croatian").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Czech").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Danish").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Farsi").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "French").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "German").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Greek").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Indonesian").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Italian").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Japanese").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Latvian").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Malagasy").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Nepali").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Portugese").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Romanian").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Russian").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Serbian").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Sinhala").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Slovenian").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Spanish").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Spanish Catalan").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Thai").first_or_create
			# Language.create_with(parent: os_lang, active: true).where(name: "Traditional Chinese").first_or_create
   #    Language.create_with(parent: os_lang, active: true).where(name: "Turkish").first_or_create
			# Language.create_with(parent: os_lang, active: true).where(name: "Urdu").first_or_create
			# Language.create_with(parent: os_lang, active: true).where(name: "Vietnamese").first_or_create
      puts "Languages seed successful"
		end
  end

  desc "Categories data seeding"
  task :seed_categories => :environment do
    ActiveRecord::Base.transaction do
			category = Category.create_with(active: true, code: 'Bok').where(name: "Book").first_or_create
			Category.create_with(parent: category, active: true, code: 'HBB').where(name: "Hard-Bound Book").first_or_create
			Category.create_with(parent: category, active: true, code: 'PBB').where(name: "Paperback Book").first_or_create
      Category.create_with(parent: category, active: true, code: 'Mag').where(name: "Magazine").first_or_create

      # Code needs to be added to following categories for seeding them
			# category = Category.create_with(active: true).where(name: "Audio/Video").first_or_create
			# Category.create_with(parent: category, active: true).where(name: "ACD").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "Audio Book").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "Cassette").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "MP3-CD").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "VCD").first_or_create
			# Category.create_with(parent: category, active: true).where(name: "Video DVD").first_or_create

			# category = Category.create_with(active: true).where(name: "Photos").first_or_create
			# Category.create_with(parent: category, active: true).where(name: "Photos B&W").first_or_create
			# Category.create_with(parent: category, active: true).where(name: "Photos Coloured").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "3D Photos").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "Framed Laminated").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "Unframed").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "Canvas").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "Glass").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "LED Backlit").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "Archival Prints").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "Photo Stand").first_or_create

			# category = Category.create_with(active: true).where(name: "Printed Material").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "Brochures").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "Introductory Material").first_or_create

			# category = Category.create_with(active: true).where(name: "Miscellaneous").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "Bags").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "Holders").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "Jute Bags").first_or_create
   #    Category.create_with(parent: category, active: true).where(name: "Polybags").first_or_create
      puts "Categories seed successful"
		end
  end

  desc "Run all tasks in this file"
  task seed_all: [:seed_languages, :seed_categories]
end
