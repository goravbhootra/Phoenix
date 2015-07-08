class AccountsContinued < ActiveRecord::Migration
  def change
    Rake::Task['create_inventory_out_vouchers_for_pos_invoices:rename_pos_invoices'].execute

    change_column_null(:account_txns, :txn_date, false)
    add_column :account_txn_details, :business_entity_location_id, :integer, null: false
    add_index :account_txn_details, :business_entity_location_id
    add_foreign_key :account_txn_details, :business_entity_locations, on_delete: :cascade

    add_column :business_entity_locations, :cash_account_id, :integer
    add_index :business_entity_locations, :cash_account_id
    add_foreign_key :business_entity_locations, :accounts, column: :cash_account_id, primary_key: :id, on_delete: :restrict

    add_column :business_entity_locations, :bank_account_id, :integer
    add_index :business_entity_locations, :bank_account_id
    add_foreign_key :business_entity_locations, :accounts, column: :bank_account_id, primary_key: :id, on_delete: :restrict
    BusinessEntityLocation.find(150).update_attributes(cash_account_id: 5)
    BusinessEntityLocation.find(152).update_attributes(cash_account_id: 3)
  end
end
