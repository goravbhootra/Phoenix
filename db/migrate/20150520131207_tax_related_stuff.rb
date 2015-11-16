class TaxRelatedStuff < ActiveRecord::Migration
  def change
    remove_column :inventory_txn_line_items, :type, :string
    remove_column :inventory_txn_line_items, :state_category_tax_rate_id, :integer
    remove_column :inventory_txn_line_items, :tax_rate, :string
    remove_column :inventory_txn_line_items, :delivered, :boolean
    add_column :inventory_txn_line_items, :tax_rate, :float, precision: 3, float: 2
    change_column_null(:inventory_txn_line_items, :tax_rate, false)
  end
end
