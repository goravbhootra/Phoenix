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
    respond_to do |format|
      format.html
      format.pdf do
        pdf = SalesReportPdf.new(InvoiceLineItem.includes([product: :language]).all)
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
        pdf = PaymentCollectionReportPdf.new(InvoicePayment.joins(:invoice).where(invoices: {primary_location_id: 150, type: 'PosInvoice' }).where("date(invoice_payments.created_at) = ?", Time.zone.now.to_date))
        send_data pdf.render, filename: "payment_collection_report",
                              type: "application/pdf",
                              disposition: 'inline'
      end
    end
  end

  private
  # Never trust parameters from the scary internet, only allow the white list through.
  def sale_report_params
    params.require(:sale_report).permit!
  end
end
