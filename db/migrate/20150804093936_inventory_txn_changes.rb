class InventoryTxnChanges < ActiveRecord::Migration
  def change
    remove_column :inventory_txns, :customer_membership_number, :string
    remove_column :inventory_txns, :tax_details, :string
    remove_column :inventory_txns, :goods_value, :decimal
    remove_column :inventory_txns, :tax_amount, :decimal

    BusinessEntity.find_by(alias_name: '(Retl Sales)').locations.destroy_all
    BusinessEntity.find_by(alias_name: '(Retl Sales)').voucher_sequences.destroy_all
    BusinessEntity.find_by(alias_name: '(Retl Sales)').destroy

    Product.update_all(active: true)
    Publisher.find_by(business_entity_id: 2).destroy
    ids = InventoryTxn.where(secondary_entity_id: 2).pluck(:id)
    InventoryTxn.where(secondary_entity_id: 2).update_all(type: 'InventoryInternalTransferVoucher', secondary_entity_id: nil, secondary_location_id: 150, voucher_sequence_id: 105)
    InventoryTxnLineItem.where(inventory_txn_id: ids).update_all("quantity_in = quantity_out")

    BusinessEntity.find_by(name: 'Chennai- BookStall').locations.destroy_all
    BusinessEntity.find_by(name: 'Chennai- BookStall').voucher_sequences.destroy_all
    BusinessEntity.find_by(name: 'Chennai- BookStall').destroy
  end
end
