class AddReservedBoolean < ActiveRecord::Migration
  def change
    drop_table :sale_invoice_payments

    add_column :business_entities, :reserved, :boolean, default: false, null: false
    add_column :currencies, :reserved, :boolean, default: false, null: false
    add_column :regions, :reserved, :boolean, default: false, null: false
    add_column :states, :reserved, :boolean, default: false, null: false
    add_column :zones, :reserved, :boolean, default: false, null: false
    add_column :centres, :reserved, :boolean, default: false, null: false
    add_column :users, :reserved, :boolean, default: false, null: false

    remove_column :inventory_vouchers, :classification, :integer
    rename_table :centres, :cities
    rename_column :business_entities, :centre_id, :city_id
    rename_column :users, :centre_id, :city_id
  end
end
