class AddModeToAccountEntries < ActiveRecord::Migration
  def change
    add_column :account_entries, :mode, :string
    change_column_null :account_entries, :mode, false
  end
end
