# Import data by invoking following in console:
# InventoryVoucherImport.import('/path/to/file.xls')
class InventoryVoucherImport < ActiveImporter::Base
  imports InventoryTxn

  column 'Sku', :sku do |sku|
    sku.to_i
  end

  column 'quantity', :quantity
  column 'ref_number', :ref_number, optional: true
  on :row_processing do
    business_entity_id = 3
    voucher_sequence_id = 2
    created_by_id = 1
    currency_id = 1
    classification = 'opening_stock'
    voucher_date = Time.zone.now.in_time_zone.strftime('%d/%m/%Y')
  end
end
