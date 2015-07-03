class MoveInventoryVouchersToTxn < ActiveRecord::Migration
  def change
    execute "alter table inventory_txn_line_items DROP CONSTRAINT quantity_in_xor_quantity_out"

    InventoryVoucher.find_each do |voucher|
      txn = InventoryTxn.new(primary_location_id: voucher.business_entity_location_id, voucher_sequence_id: voucher.voucher_sequence_id, currency_id: voucher.currency_id, total_amount: -(voucher.total_amount), voucher_date: voucher.voucher_date, number_prefix: voucher.number_prefix, ref_number: voucher.ref_number, created_at: voucher.created_at, updated_at: voucher.updated_at, created_by_id: voucher.created_by_id, secondary_location_id: voucher.receiving_business_entity_location_id, goods_value: -(voucher.total_amount), type: 'InventoryInternalTransferVoucher')
      txn.remarks = voucher.remarks if voucher.remarks.present?
      voucher.line_items.find_each do |line_item|
        txn.line_items.build(product_id: line_item.product_id, quantity_out: -(line_item.quantity), amount: -(line_item.amount), created_at: line_item.created_at, updated_at: line_item.updated_at, price: line_item.price, quantity_in: line_item.received_quantity)
      end
      txn.save!
      voucher.destroy!
    end

    drop_table :inventory_voucher_line_items
    drop_table :inventory_vouchers
  end
end
