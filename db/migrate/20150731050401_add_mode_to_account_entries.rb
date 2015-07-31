class AddModeToAccountEntries < ActiveRecord::Migration
  def change
    add_column :account_entries, :mode, :string
    AccountEntry.pluck(:account_id).uniq.sort.each { |id| AccountEntry.where(account_id: id).update_all(mode: Account.find(id).type) }
    change_column_null :account_entries, :mode, false
  end
end
