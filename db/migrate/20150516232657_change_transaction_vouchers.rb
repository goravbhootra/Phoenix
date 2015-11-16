class ChangeTransactionVouchers < ActiveRecord::Migration
  def change
    add_column :business_entities, :classification, :integer, null: false, default: 1
    add_index :business_entities, :classification
    remove_column :business_entity_locations, :status, :integer

    rename_table :sale_invoices, :inventory_txns
    remove_index :sale_invoice_line_items, ([:sale_invoice_id, :product_id])
    rename_table :sale_invoice_line_items, :inventory_txn_line_items
    rename_column :inventory_txn_line_items, :sale_invoice_id, :inventory_txn_id
    add_index :inventory_txn_line_items, ([:inventory_txn_id, :product_id]), unique: true, name: 'idx_inventory_txn_line_items_on_sale_invoice_id_and_product_id'
    add_column :inventory_txns, :customer_membership_number, :string, limit: 9
    rename_column :inventory_txns, :business_entity_location_id, :primary_location_id
    add_column :inventory_txns, :primary_entity_id, :integer
    add_index :inventory_txns, :primary_entity_id
    add_foreign_key :inventory_txns, :business_entities, column: :primary_entity_id, on_delete: :restrict

    add_column :inventory_txns, :secondary_entity_id, :integer
    add_index :inventory_txns, :secondary_entity_id
    add_foreign_key :inventory_txns, :business_entities, column: :secondary_entity_id, on_delete: :restrict
    add_column :inventory_txns, :secondary_location_id, :integer
    add_index :inventory_txns, :secondary_location_id
    add_foreign_key :inventory_txns, :business_entities, column: :secondary_location_id, on_delete: :restrict
    add_column :inventory_txns, :type, :string
    change_column_null(:inventory_txns, :type, false)

    rename_column :sale_invoice_payments, :sale_invoice_id, :inventory_txn_id

    change_column_null(:inventory_txns, :primary_entity_id, false)
    execute "alter table inventory_txns ADD CONSTRAINT secondary_account_xor_location check(
      (secondary_entity_id IS NOT null)::integer +
      (secondary_location_id  IS NOT null)::integer = 1
    );"

    add_column :users, :membership_number, :string, limit: 9, null: false
    add_index :users, :membership_number, unique: true

    rename_column :sale_invoice_payments, :payment_mode_id, :mode_id
    remove_column :inventory_txns, :member_id, :integer
    remove_column :orders, :member_id, :integer
    drop_table :location_inventory_levels
    remove_column :users, :member_id, :integer
    drop_table :members
  end
end
