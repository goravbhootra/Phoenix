class InvoicesVouchersController < ApplicationController
  power :invoices_vouchers

  def pending_list
    @pending_vouchers_list = InventoryTxn.includes(:created_by, :secondary_entity, primary_location: :business_entity).where(invoice_id: nil).where("secondary_entity_id IS NOT null").where(business_entities: { reserved: false })
  end
end
