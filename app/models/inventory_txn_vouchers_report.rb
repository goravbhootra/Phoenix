class InventoryTxnVouchersReport < ActiveType::Object

  def self.inventory_internal_transfer_vouchers_line_items_to_csv(options = {})
    # Chennai Business Entity - Tiruvallur Location
    inventory_txn_ids = InventoryInternalTransferVoucher.where('primary_location_id = ? OR secondary_entity_id = ?', 153, 154).pluck(:id)
    product_ids = InventoryTxnLineItem.where(inventory_txn_id: inventory_txn_ids).pluck(:product_id).uniq
    product_details = Product.product_details_by_ids(product_ids)

    CSV.generate(options) do |csv|
      csv << ['Voucher Date', 'Voucher Number', 'SKU', 'Product Name', 'Category Code', 'Language Code', 'Quantity Sent', 'Quantity Received', 'Created By', 'Created At', 'Updated At']

      InventoryTxnLineItem.includes(:inventory_txn).where(inventory_txn_id: inventory_txn_ids).order("inventory_txns.voucher_date, inventory_txns.number").find_each do |line_item|
        csv << [
          line_item.inventory_txn.voucher_date.strftime('%d/%m/%Y'),
          line_item.inventory_txn.number,
          product_details[line_item.product_id][:sku],
          product_details[line_item.product_id][:name],
          product_details[line_item.product_id][:category_code],
          product_details[line_item.product_id][:language_code],
          line_item.quantity_out, line_item.quantity_in,
          line_item.inventory_txn.created_by_name,
          line_item.updated_at,
          line_item.created_at
        ]
      end
    end
  end
end
