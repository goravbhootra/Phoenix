module InvoiceLineItemsExtension
  def total_amount
    reject(&:marked_for_destruction?).sum(&:amount)
  end

  def total_quantity
    -reject(&:marked_for_destruction?).sum(&:quantity) # Quantity is stored as negative
  end
end
