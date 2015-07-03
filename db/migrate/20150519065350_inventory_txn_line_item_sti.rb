class InventoryTxnLineItemSti < ActiveRecord::Migration
  def change
    add_column :inventory_txn_line_items, :type, :string
    InventoryTxnLineItem.update_all(type: 'PosSaleInvoiceLineItem')
    change_column_null(:inventory_txn_line_items, :type, false)

    BusinessEntity.all.each { |be| VoucherSequence.create!(business_entity_id: be.id, classification: 2, valid_from: "1/4/2015", active: true) }
  end
end
