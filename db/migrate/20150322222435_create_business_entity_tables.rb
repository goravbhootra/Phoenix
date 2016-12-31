class CreateBusinessEntityTables < ActiveRecord::Migration
  def change
    enable_extension 'hstore'
    create_table :business_entities do |t|
      t.string     :name,                     null: false, limit: 200
      t.string     :alias_name,               limit: 40, null: false
      t.boolean    :active,                   default: true, null: false
      t.belongs_to :city,                   null: false, required: true
      t.integer    :registration_status,      null: false, comment: "registered_branch: 1, additional_place_of_business: 2, registered_company: 3, unregistered_company: 4, registered_individual: 5, unregistered_individual: 6"
      t.string     :email,                    limit: 150
      t.text       :primary_address,          null: false
      t.text       :shipping_address
      t.boolean    :reserved,                 null: false, default: false
      t.string     :contact_number_primary,   limit: 15
      t.string     :contact_number_secondary, limit: 15
      t.hstore     :legal_details
      t.integer    :position
      t.integer    :classification,           null: false, default: 1
      t.timestamps                            null: false
      t.index([:name, :city_id], unique: true)
      t.index(:alias_name, unique: true)
      t.index(:classification)
    end
    add_foreign_key :business_entities, :cities, on_delete: :restrict

    create_table :voucher_sequences do |t|
      t.belongs_to :business_entity,      null: false
      t.integer    :classification,       null: false, default: 1, comment: "sale_invoice: 1, order: 2"
      t.string     :number_prefix,        limit: 8
      t.integer    :starting_number,      null: false, default: 1
      t.datetime   :valid_from,           null: false
      t.datetime   :valid_till
      t.text       :terms_conditions
      t.boolean    :active,               null: false, default: true
      t.timestamps                        null: false
    end
    add_foreign_key :voucher_sequences, :business_entities, on_delete: :restrict
    execute "CREATE UNIQUE INDEX idx_voucher_seq_on_business_entity_n_classification_n_valid_from ON voucher_sequences (classification, business_entity_id, valid_from) WHERE number_prefix IS NULL"
    execute "CREATE UNIQUE INDEX idx_voucher_seq_on_num_prfx_bus_entity_n_clasfctn_n_valid_from ON voucher_sequences (classification, business_entity_id, valid_from, number_prefix) WHERE number_prefix IS NOT NULL"

    create_table :accounts do |t|
      t.belongs_to :business_entity,            null: false
      t.string     :name,                       limit: 100
      t.string     :alias_name,                 limit: 25
      t.string     :type,                       null: false
      t.boolean    :contra,                     default: false, null: false
      t.boolean    :reserved,                   default: false, null: false
      t.boolean    :active,                     default: true, null: false
      t.timestamps                              null: false
      t.index([:name, :business_entity_id], unique: true)
      t.index([:alias_name, :business_entity_id], unique: true)
    end
    add_foreign_key :accounts, :business_entities, on_delete: :restrict

    create_table :account_txns do |t|
      t.belongs_to :business_entity,            null: false
      t.belongs_to :currency,                   null: false
      t.belongs_to :voucher_sequence,           null: false
      t.belongs_to :created_by,                 null: false
      t.string     :type,                       null: false
      t.string     :number_prefix,              limit: 8
      t.integer    :number,                     null: false
      t.text       :remarks
      t.datetime   :txn_date,                   null: false
      t.integer    :status,                     null: false
      t.string     :ref_number,                 limit: 30
      t.timestamps                              null: false
      t.index([:business_entity_id, :number_prefix, :number], unique: true, name: 'idx_account_txns_on_business_entity_n_number_prefix_n_number')
      t.index(:currency_id)
      t.index(:voucher_sequence_id)
      t.index(:created_by_id)
    end
    add_foreign_key :account_txns, :business_entities, on_delete: :restrict
    add_foreign_key :account_txns, :currencies, on_delete: :restrict
    add_foreign_key :account_txns, :voucher_sequences, on_delete: :restrict
    add_foreign_key :account_txns, :users, column: :created_by_id, primary_key: :id, on_delete: :restrict

    create_table :account_entries do |t|
      t.belongs_to :account_txn,                null: false
      t.belongs_to :account,                    null: false
      t.string     :type,                       null: false # debit, credit
      t.decimal    :amount,                     null: false, precision: 10, scale: 2
      t.string     :mode,                       null: false
      t.text       :remarks
      t.hstore     :additional_info
      t.timestamps                              null: false
      t.index([:account_txn_id, :account_id])
    end
    add_foreign_key :account_entries, :account_txns, on_delete: :cascade
    add_foreign_key :account_entries, :accounts, on_delete: :cascade

    create_table :business_entity_locations do |t|
      t.belongs_to :business_entity,          null: false
      t.belongs_to :cash_account
      t.belongs_to :bank_account
      t.belongs_to :sales_account
      t.string     :name,                     null: false
      t.boolean    :active,                   default: true, null: false
      t.integer    :position
      t.timestamps                            null: false
      t.index([:business_entity_id, :name], unique: true)
      t.index(:cash_account_id)
      t.index(:bank_account_id)
      t.index(:sales_account_id)
    end
    add_foreign_key :business_entity_locations, :business_entities, on_delete: :restrict
    add_foreign_key :business_entity_locations, :accounts, column: :cash_account_id,
                    primary_key: :id, on_delete: :restrict
    add_foreign_key :business_entity_locations, :accounts, column: :bank_account_id,
                    primary_key: :id, on_delete: :restrict
    add_foreign_key :business_entity_locations, :accounts, column: :sales_account_id,
                    primary_key: :id, on_delete: :restrict

    create_table :publishers do |t|
      t.belongs_to :business_entity,          null: false
      t.boolean    :active,                   null: false, default: true
      t.timestamps                            null: false
      t.index(:business_entity_id, unique: true)
    end
    add_foreign_key :publishers, :business_entities, on_delete: :restrict
  end
end
