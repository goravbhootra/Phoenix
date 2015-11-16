class RemoveAdditionalDetails < ActiveRecord::Migration
  def change
    remove_column :inventory_txns, :additional_charges_details, :hstore
  end
end
