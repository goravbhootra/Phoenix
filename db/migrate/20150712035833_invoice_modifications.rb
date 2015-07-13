class InvoiceModifications < ActiveRecord::Migration
  def change
    drop_table :invoice_line_items
    rename_table :account_txn_line_items, :invoice_line_items

    add_column :account_entries, :additional_info, :hstore

    arr = AccountEntry::Debit.where.not(remarks: nil).pluck(:id, :remarks).to_h
    arr.each do |k,v|
      remarks = v
      arr[k] = Hash.new
      eval(remarks).to_a.each { |rem| arr[k][rem[0]] = rem[1] }
    end
    arr.keys.each do |id|
      AccountEntry::Debit.find(id).update_columns(additional_info: arr[id])
    end

    create_table :bank_reconciliations do |t|
      t.belongs_to :account_entry,            null: false
      t.belongs_to :reconciled_by
      t.datetime   :reconciled_at
      t.timestamps                            null: false
      t.index(:account_entry_id, unique: true)
    end
    add_foreign_key :bank_reconciliations, :account_entries, on_delete: :restrict
    add_foreign_key :bank_reconciliations, :users, column: :reconciled_by_id, primary_key: :id, on_delete: :restrict
  end
end
