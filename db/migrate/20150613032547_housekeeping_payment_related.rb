class HousekeepingPaymentRelated < ActiveRecord::Migration
  def change
    drop_table :inventory_txn_payments
  end
end
