class RoleAndInvoiceRelated < ActiveRecord::Migration
  def change
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
      t.index([:user_id, :role_id, :business_entity_id], unique: true, where: 'business_entity_id is NOT NULL', name: 'idx_user_on_role_on_business_entity')
      t.index([:user_id, :role_id, :business_entity_location_id], unique: true,
              where: 'business_entity_location_id is NOT NULL',
              name: 'idx_user_on_role_on_business_entity_location'
             )
      t.index([:user_id, :role_id], unique: true,
              where: 'business_entity_id is NOT NULL AND business_entity_location_id is NOT NULL'
             )
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

    # admin = Role.find_by(name: 'admin')
    # power_user = Role.find_by(name: 'power_user')
    # business_entity_location_admin = Role.find_by(name: 'business_entity_location_admin')
    # pos_user = Role.find_by(name: 'pos_user')

    create_table :invoice_line_items do |t|
      t.belongs_to :account_txn,                null: false
      t.belongs_to :product,                    null: false
      t.belongs_to :state_category_tax_rate
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
      t.index(:state_category_tax_rate_id)
    end
    add_foreign_key :invoice_line_items, :account_txns, on_delete: :cascade
    add_foreign_key :invoice_line_items, :products, on_delete: :cascade
    add_foreign_key :invoice_line_items, :state_category_tax_rates, on_delete: :restrict

    create_table :invoice_headers do |t|
      t.belongs_to :account_txn,                null: false
      t.belongs_to :business_entity_location,   null: false
      t.text       :address
      t.hstore     :legal_details
      t.string     :customer_membership_number, limit: 9
      t.timestamps                              null: false
      t.index(:account_txn_id, unique: true)
      t.index(:business_entity_location_id)
    end
    add_foreign_key :invoice_headers, :account_txns, on_delete: :cascade
    add_foreign_key :invoice_headers, :business_entity_locations, on_delete: :cascade
  end
end
