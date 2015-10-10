class PosInvoicesReportsController < ApplicationController
  power :pos_invoice_reports, map: {
                          [:pos_invoices_list_with_payment] => :pos_invoices_list_with_payment,
                          [:pos_invoice_line_items] => :pos_invoice_line_items
                        }

  def pos_invoices_list_with_payment
    respond_to do |format|
      format.csv { send_data PosInvoicesReport.invoice_list_with_payments_to_csv, filename: "sale_payment_details_#{Time.zone.now.in_time_zone.strftime('%Y%m%d')}.csv" }
      format.xls { send_data PosInvoicesReport.invoice_list_with_payments_to_csv(col_sep: "\t"), filename: "sale_payment_details_#{Time.zone.now.in_time_zone.strftime('%Y%m%d')}.xls" }
    end
  end

  def pos_invoice_line_items
    respond_to do |format|
      format.csv { send_data PosInvoicesReport.pos_invoice_line_items_to_csv, filename: "pos_invoice_line_items_#{Time.zone.now.in_time_zone.strftime('%Y%m%d')}.csv" }
      format.xls { send_data PosInvoicesReport.pos_invoice_line_items_to_csv(col_sep: "\t"), filename: "pos_invoice_line_items_#{Time.zone.now.in_time_zone.strftime('%Y%m%d')}.xls" }
    end
  end
end
