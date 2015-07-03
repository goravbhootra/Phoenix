class AddReservedBoolean < ActiveRecord::Migration
  def change
    rename_table :sale_invoice_payments, :inventory_txn_payments
    InventoryTxn.where(type: 'PosSaleInvoice').update_all(type: 'PosInvoice')

    add_column :business_entities, :reserved, :boolean, default: false, null: false
    add_column :currencies, :reserved, :boolean, default: false, null: false
    add_column :regions, :reserved, :boolean, default: false, null: false
    add_column :states, :reserved, :boolean, default: false, null: false
    add_column :zones, :reserved, :boolean, default: false, null: false
    add_column :centres, :reserved, :boolean, default: false, null: false
    add_column :users, :reserved, :boolean, default: false, null: false

    Currency.where(name: 'Virtual').update_all(reserved: true)
    Region.where(name: 'Virtual').update_all(reserved: true)
    State.where(name: 'Virtual').update_all(reserved: true)
    Zone.where(name: 'Virtual').update_all(reserved: true)
    Centre.where(name: 'Virtual').update_all(reserved: true)
    User.where(name: 'Virtual').update_all(reserved: true)

    BusinessEntityUser.where(user: User.find_by(membership_number: 'ONLIN1504')).destroy_all
    User.find_by(membership_number: 'ONLIN1504').update_attributes(reserved: true)

    virtual_centre = Centre.unscoped.find_by(name: 'Virtual')
    be_opening_stk = BusinessEntity.create(name: 'Opening Stock', alias_name: '(Opening Stk)', active: true, centre: virtual_centre, registration_status: 10, email: 'virtual@gorav.in', primary_address: 'System Account', classification: 2, reserved: true)
    be_corpus = BusinessEntity.create(name: 'Corpus Distribution', alias_name: '(Corpus Dist)', active: true, centre: virtual_centre, registration_status: 10, email: 'virtual@gorav.in', primary_address: 'System Account', classification: 1, reserved: true)
    BusinessEntity.create(name: 'Gratis Distribution', alias_name: '(Gratis Dist)', active: true, centre: virtual_centre, registration_status: 10, email: 'virtual@gorav.in', primary_address: 'System Account', classification: 1, reserved: true)
    BusinessEntity.find_by(name: 'POS_Sales').update_attributes(reserved: true)

    InventoryVoucher.where(classification: 1).find_each do |voucher|
      op_txn = InventoryTxn.new(primary_location_id: voucher.business_entity_location_id, voucher_sequence_id: voucher.voucher_sequence_id, currency_id: voucher.currency_id, total_amount: voucher.total_amount, voucher_date: voucher.voucher_date, number_prefix: voucher.number_prefix, ref_number: voucher.ref_number, created_at: voucher.created_at, updated_at: voucher.updated_at, created_by_id: voucher.created_by_id, secondary_entity_id: be_opening_stk.id, goods_value: voucher.total_amount, type: 'InventoryInVoucher')
      op_txn.remarks = voucher.remarks
      voucher.line_items.find_each do |line_item|
        op_txn.line_items.build(product_id: line_item.product_id, quantity_in: line_item.quantity, amount: line_item.amount, created_at: line_item.created_at, updated_at: line_item.updated_at, price: line_item.price)
      end
      op_txn.save!
      voucher.destroy!
    end

    InventoryVoucher.where(classification: 4).find_each do |voucher|
      corpus_txn = InventoryTxn.new(primary_location_id: voucher.business_entity_location_id, voucher_sequence_id: voucher.voucher_sequence_id, currency_id: voucher.currency_id, total_amount: -(voucher.total_amount), voucher_date: voucher.voucher_date, number_prefix: voucher.number_prefix, ref_number: voucher.ref_number, created_at: voucher.created_at, updated_at: voucher.updated_at, created_by_id: voucher.created_by_id, secondary_entity_id: be_corpus.id, goods_value: -(voucher.total_amount), type: 'InventoryOutVoucher')
      corpus_txn.remarks = voucher.remarks
      voucher.line_items.find_each do |line_item|
        corpus_txn.line_items.build(product_id: line_item.product_id, quantity_out: -(line_item.quantity), amount: -(line_item.amount), created_at: line_item.created_at, updated_at: line_item.updated_at, price: line_item.price)
      end
      corpus_txn.save!
      voucher.destroy!
    end
    # execute "alter table inventory_txn_line_items DROP CONSTRAINT quantity_in_xor_quantity_out"

    remove_column :inventory_vouchers, :classification, :integer
  end
end
