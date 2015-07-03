class IssueFix < ActiveRecord::Migration
  def change
    remove_foreign_key :inventory_txns, column: :secondary_location_id
    add_foreign_key :inventory_txns, :business_entity_locations, column: :secondary_location_id, on_delete: :restrict
  end
end
