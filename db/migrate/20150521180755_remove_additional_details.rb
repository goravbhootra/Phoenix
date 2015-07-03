class RemoveAdditionalDetails < ActiveRecord::Migration
  def change
    remove_column :inventory_txns, :additional_charges_details, :hstore

    BusinessEntity.all.each { |be| VoucherSequence.create!(business_entity_id: be.id, classification: 3, valid_from: "1/4/2015", active: true) }
  end
end
