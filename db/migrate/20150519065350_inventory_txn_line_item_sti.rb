class InventoryTxnLineItemSti < ActiveRecord::Migration
  def change
    add_column :inventory_txn_line_items, :type, :string
    change_column_null(:inventory_txn_line_items, :type, false)
  end
end
