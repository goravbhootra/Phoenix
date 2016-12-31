class CreateBankReconciliations < ActiveRecord::Migration
  def change
    create_table :bank_reconciliations do |t|
      t.belongs_to :account_entry,            null: false
      t.belongs_to :reconciled_by
      t.datetime   :reconciled_at
      t.timestamps                            null: false
      t.index(:account_entry_id, unique: true)
    end
    add_foreign_key :bank_reconciliations, :account_entries, on_delete: :restrict
    add_foreign_key :bank_reconciliations, :users, column: :reconciled_by_id, primary_key: :id, on_delete: :restrict

    add_column :users, :cash_account_id, :integer
    add_index :users, :cash_account_id
    add_foreign_key :users, :accounts, column: :cash_account_id, primary_key: :id, on_delete: :restrict
  end
end
