class CentreToCity < ActiveRecord::Migration
  def change
    rename_table :centres, :cities
    rename_column :business_entities, :centre_id, :city_id
    rename_column :users, :centre_id, :city_id
  end
end
