class UserRoleFix < ActiveRecord::Migration
  def change
    remove_index :user_roles, ([:user_id, :role_id])

    add_index :user_roles, ([:user_id, :role_id]), unique: true, where: 'business_entity_id is NOT NULL AND business_entity_location_id is NOT NULL'
  end
end
