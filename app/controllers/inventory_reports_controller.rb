class InventoryReportsController < ApplicationController
  power :inventory_reports

  def stock_summary
    # build_inventory_report
    # params[:from_date] = '01/04/2015'
    # params[:to_date] = Time.zone.now.strftime('%d/%m/%Y')
    # puts "$$$$$$$$$$$$$$$$$$$$$$$$$$ #{params}"

    filter_params = Hash.new
    # if @inventory_report.save!
      filter_params[:location_id] = params[:location_id]
      filter_params[:from_date] = params[:from_date] || '01/04/2015'
      filter_params[:to_date] = params[:to_date] || Time.zone.now.strftime('%d/%m/%Y')
    # else
      # puts "$$$$$$$$$$$$$$$$$$$$$$$ params"
    # end

    respond_to do |format|
      format.xls { send_data InventoryReport.locationwise_stock_summary({col_sep: "\t"}, filter_params), filename: "stock_summary_#{Time.zone.now.in_time_zone.strftime('%Y%m%d')}.xls" }
    end
  end

  def adjustment_transactions
    @inventory_txn_line_items = InventoryCalculations.adjustment_transactions
  end

  private

  def build_inventory_report
      @inventory_report = InventoryReport.new(inventory_report_params)
  end

  def inventory_report_params
      inventory_report_params = params[:inventory_report]
      inventory_report_params.permit(:from_date, :to_date, :location_id) if inventory_report_params
  end
end
