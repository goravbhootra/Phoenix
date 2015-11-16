class MoveInventoryVouchersToTxn < ActiveRecord::Migration
  def change
    execute "alter table inventory_txn_line_items DROP CONSTRAINT quantity_in_xor_quantity_out"

    drop_table :inventory_voucher_line_items
    drop_table :inventory_vouchers
  end
end
