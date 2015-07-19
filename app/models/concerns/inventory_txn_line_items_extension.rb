module InventoryTxnLineItemsExtension
  def total_quantity
    reject(&:marked_for_destruction?).sum(&:quantity_out)
  end

  def total_amount
    reject(&:marked_for_destruction?).sum(&:amount)
  end
end
