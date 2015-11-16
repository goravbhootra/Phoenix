class InventoryTxnChanges < ActiveRecord::Migration
  def change
    remove_column :inventory_txns, :customer_membership_number, :string
    remove_column :inventory_txns, :tax_details, :string
    remove_column :inventory_txns, :goods_value, :decimal
    remove_column :inventory_txns, :tax_amount, :decimal
  end
end
