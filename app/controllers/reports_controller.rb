class ReportsController < ApplicationController
  # power :reports, map: { [:sales, :payment_collection] => :admin_reports }
  power :reports

  # before_action :set_inventory_out_voucher, only: [:edit, :update, :destroy]

  def stock_summary
    respond_to do |format|
      format.html
      format.pdf do
        pdf = StockSummaryPdf.new()
        send_data pdf.render, filename: "stock_summary",
                              type: "application/pdf",
                              disposition: 'inline'
      end
    end
  end

  def sales
    @invoice_line_items = InvoiceLineItem.where(account_txn_id: InvoiceHeader.where(business_entity_location_id: GlobalSettings.current_bookstall_id).pluck(:account_txn_id)).includes([product: :language]).all
    respond_to do |format|
      format.html
      format.pdf do
        pdf = SalesReportPdf.new(@invoice_line_items)
        send_data pdf.render, filename: "sale_reports",
                              type: "application/pdf",
                              disposition: 'inline'
      end
    end
  end

  def payment_collection
    respond_to do |format|
      format.html
      format.pdf do
        pdf = PosInvoiceCashCollectionPdf.new
        send_data pdf.render, filename: "payment_collection_report",
                              type: "application/pdf",
                              disposition: 'inline'
      end
    end
  end

  def sales_summary_userwise
    respond_to do |format|
      format.html
      format.pdf do
        pdf = SalesSummaryUserwisePdf.new
        send_data pdf.render, filename: "payment_collection_report",
                              type: "application/pdf",
                              disposition: 'inline'
      end
    end
  end

  private
  def sale_report_params
    params.require(:sale_report).permit!
  end
end
