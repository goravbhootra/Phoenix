class InventoryTxnVouchersReportsController < ApplicationController
  power :inventory_txn_reports, map: {
                          [:inventory_internal_transfer_vouchers_line_items] => :inventory_internal_transfer_vouchers_line_items
                        }

  def inventory_internal_transfer_vouchers_line_items
    respond_to do |format|
      format.csv { send_data InventoryTxnVouchersReport.inventory_internal_transfer_vouchers_line_items_to_csv, filename: "inventory_internal_transfer_vouchers_line_items_#{Time.zone.now.in_time_zone.strftime('%Y%m%d')}.csv" }
      format.xls { send_data InventoryTxnVouchersReport.inventory_internal_transfer_vouchers_line_items_to_csv(col_sep: "\t"), filename: "inventory_internal_transfer_vouchers_line_items_#{Time.zone.now.in_time_zone.strftime('%Y%m%d')}.xls" }
    end
  end
end
