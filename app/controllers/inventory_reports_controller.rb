class InventoryReportsController < ApplicationController
  power :inventory_reports

  def stock_summary
    respond_to do |format|
      format.xls { send_data InventoryReport.locationwise_stock_summary(col_sep: "\t"), filename: "stock_summary_#{Time.zone.now.in_time_zone.strftime('%Y%m%d')}.xls" }
    end
  end

  def opening_stock

  end

  def adjustment_transactions
    @inventory_txn_line_items = InventoryCalculations.adjustment_transactions
  end
end
