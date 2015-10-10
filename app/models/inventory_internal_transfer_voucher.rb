class InventoryInternalTransferVoucher < InventoryTxn

  def process_calculations
    VoucherCalculations.new({voucher: self, quantity_field: 'quantity_out'}).process_totals
    errors.add(:base, 'No products added! Total amount should be more than 0') and return false if self.total_amount < 1
  end

  def mandatory_values_check(attributed)
    if attributed['product_id'].blank? || attributed['quantity_out'].to_i < 1
      # handle new records with invalid data
      return true if attributed['id'].blank?

      # handle existing records with invalid data
      attributed['_destroy'] = true if attributed['id'].present?
    end
    false
  end

  def consolidate_line_items_on_product
    VoucherConsolidateLineItems.new({voucher: self, association_name: 'line_items', attrib_id: 'product_id', consolidate: 'quantity_out'}).consolidate_with_same_attribute
  end
end
