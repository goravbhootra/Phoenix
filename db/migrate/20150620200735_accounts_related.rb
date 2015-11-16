class AccountsRelated < ActiveRecord::Migration
  def change
    remove_column :business_entity_locations, :default, :boolean
    drop_table :business_entity_users

    rename_column :users, :roles, :old_roles
    create_table :roles do |t|
      t.string     :name,                    null: false, limit: 40
      t.boolean    :mail_enabled,            default: true, null: false
      t.boolean    :reserved,                default: false, null: false
      t.boolean    :active,                  default: true, null: false
      t.timestamps                           null: false
      t.index(:name, unique: true)
    end
    Role.create!([
      {name: 'admin', mail_enabled: true, reserved: true, active: true},
      {name: 'power_user', mail_enabled: true, active: true},
      {name: 'business_entity_admin', mail_enabled: true, active: true},
      {name: 'business_entity_location_admin', mail_enabled: true, active: true},
      {name: 'pos_user', mail_enabled: true, active: true}
      ])

    create_table :user_roles do |t|
      t.belongs_to :user,                     null: false
      t.belongs_to :role,                     null: false
      t.belongs_to :business_entity
      t.belongs_to :business_entity_location
      t.boolean    :global,                   default: false, null: false
      t.boolean    :active,                   default: true, null: false
      t.timestamps                            null: false
      t.index([:user_id, :role_id], unique: true)
      t.index([:user_id, :role_id, :business_entity_id], unique: true, where: 'business_entity_id is NOT NULL', name: 'idx_user_on_role_on_business_entity')
      t.index([:user_id, :role_id, :business_entity_location_id], unique: true, where: 'business_entity_location_id is NOT NULL', name: 'idx_user_on_role_on_business_entity_location')
    end
    add_foreign_key :user_roles, :users, on_delete: :restrict
    add_foreign_key :user_roles, :roles, on_delete: :restrict
    add_foreign_key :user_roles, :business_entities, on_delete: :restrict
    add_foreign_key :user_roles, :business_entity_locations, on_delete: :restrict
    execute "alter table user_roles ADD CONSTRAINT business_entity_xor_location_xor_global check(
      (business_entity_id IS NOT null)::integer +
      (business_entity_location_id  IS NOT null)::integer +
      (global)::integer = 1
    );"

    admin = Role.find_by(name: 'admin')
    power_user = Role.find_by(name: 'power_user')
    business_entity_location_admin = Role.find_by(name: 'business_entity_location_admin')
    pos_user = Role.find_by(name: 'pos_user')

    remove_column :users, :old_roles, :integer

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
      t.datetime   :txn_date
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
      t.integer    :order,                      null: false
      t.text       :remarks
      t.boolean    :active,                     default: true, null: false
      t.timestamps                              null: false
      t.index([:account_txn_id, :account_id])
    end
    add_foreign_key :account_entries, :account_txns, on_delete: :cascade
    add_foreign_key :account_entries, :accounts, on_delete: :cascade

    create_table :account_txn_line_items do |t|
      t.belongs_to :account_txn,                null: false
      t.belongs_to :product,                    null: false
      t.integer    :quantity,                   null: false
      t.decimal    :price,                      precision: 10,  scale: 2, null: false
      t.decimal    :goods_value,                precision: 12,  scale: 2, null: false
      t.decimal    :tax_rate,                   precision: 5, scale: 2, null: false
      t.decimal    :tax_amount,                 precision: 10,  scale: 2, null: false
      t.decimal    :amount,                     precision: 12,  scale: 2, null: false
      t.timestamps                              null: false
      t.index(:account_txn_id)
      t.index(:product_id)
      t.index([:account_txn_id, :product_id], unique: true)
    end
    add_foreign_key :account_txn_line_items, :account_txns, on_delete: :cascade
    add_foreign_key :account_txn_line_items, :products, on_delete: :cascade

    create_table :account_txn_details do |t|
      t.belongs_to :account_txn,                null: false
      t.text       :address
      t.hstore     :legal_details
      t.string     :customer_membership_number, limit: 9
      t.timestamps                              null: false
    end
    add_foreign_key :account_txn_details, :account_txns, on_delete: :cascade
  end
end
