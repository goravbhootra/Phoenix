class CashAccountForUser < ActiveRecord::Migration
  def change
    add_column :users, :cash_account_id, :integer
    add_index :users, :cash_account_id
    add_foreign_key :users, :accounts, column: :cash_account_id, primary_key: :id, on_delete: :restrict
  end
end
