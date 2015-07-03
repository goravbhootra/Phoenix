class CreateBusinessEntityTables < ActiveRecord::Migration
  def change
    enable_extension 'hstore'
    # rails g scaffold business_entity name:string centre:belongs_to ancestry status:integer email primary_address:text shipping_address:text contact_number_primary contact_number_secondary vat_number service_tax_number pan_number cst_number ie_code
    create_table :business_entities do |t|
      t.string     :name,                     null: false, limit: 200
      t.string     :alias_name,               limit: 40, null: false
      t.boolean    :active,                   default: true, null: false
      t.belongs_to :centre,                   null: false, required: true
      t.integer    :registration_status,      null: false, comment: "registered_branch: 1, additional_place_of_business: 2, registered_company: 3, unregistered_company: 4, registered_individual: 5, unregistered_individual: 6"
      t.string     :email,                    limit: 150
      t.text       :primary_address,          null: false
      t.text       :shipping_address
      t.string     :contact_number_primary,   limit: 15
      t.string     :contact_number_secondary, limit: 15
      t.hstore     :legal_details
      t.integer    :position
      t.timestamps                            null: false
      t.index([:name, :centre_id], unique: true)
      t.index(:alias_name, unique: true)
    end
    add_foreign_key :business_entities, :centres, on_delete: :restrict

    create_table :business_entity_users do |t|
      t.belongs_to :business_entity,          null: false, required: true
      t.belongs_to :user,                     null: false, required: true
      t.boolean    :active,                   default: true, null: false
      t.string     :designation,              limit: 30
      t.integer    :position
      t.timestamps                            null: false
      t.index([:business_entity_id, :user_id], unique: true)
    end
    add_foreign_key :business_entity_users, :business_entities, on_delete: :restrict
    add_foreign_key :business_entity_users, :users, on_delete: :restrict

    create_table :business_entity_locations do |t|
      t.belongs_to :business_entity,          null: false
      t.string     :name,                     null: false
      t.boolean    :default,                  null: false, default: false
      t.boolean    :active,                   default: true, null: false
      t.integer    :position
      t.timestamps                            null: false
      t.index([:business_entity_id, :name], unique: true)
    end
    add_foreign_key :business_entity_locations, :business_entities, on_delete: :restrict

    add_column :business_entity_locations, :status, :integer, null: false

    create_table :publishers do |t|
      t.belongs_to :business_entity,          null: false
      t.boolean    :active,                   null: false, default: true
      t.timestamps                            null: false
      t.index(:business_entity_id, unique: true)
    end
    add_foreign_key :publishers, :business_entities, on_delete: :restrict
  end
end
