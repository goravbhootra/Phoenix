require 'prawn'
require 'prawn/table'

# This class is responsible for generating a pdf for an invoice. It assumes that
# you have installed pdf library called prawn. Just pass an invoice, and call
# render by passing the file.
#
# generator = PdfGenerator.new(invoice)
# generator.render('/path/to/pdf-file/to/be/generated')
#
class PdfGenerator
  def initialize(invoice)
    @invoice = invoice
  end
  attr_reader :invoice

  def render(file)
    Prawn::Document.generate(file) do |pdf|
      render_headers(pdf)
      render_details(pdf)
      render_summary(pdf)
    end
  end

  private

  def render_headers(pdf)
    pdf.table([ ['POS Invoice'] ], width: 540, cell_style: {padding: 0}) do
      row(0..10).borders = []
      cells.column(0).style(size: 20, font_style: :bold, valign: :center)
    end
  end

  # Renders details about pdf. Shows recipient name, invoice date and id
  def render_details(pdf)
    pdf.move_down 10
    pdf.stroke_horizontal_rule
    pdf.move_down 15

    # billing_details =
    #   pdf.make_table([ ['Billed to:'], [recipient_name] ],
    #                  width: 355, cell_style: {padding: 0}) do
    #   row(0..10).style(size: 9, borders: [])
    #   row(0).column(0).style(font_style: :bold)
    # end

    invoice_date = invoice.invoice_date.strftime('%d/%m/%Y')
    invoice_number   = invoice.number
    invoice_details =
      pdf.make_table([ ['Invoice Date:', invoice_date], ['Invoice No:', invoice_number] ],
                     width: 185, cell_style: {padding: 5, border_width: 0.5}) do
      row(0..10).style(size: 9)
      row(0..10).column(0).style(font_style: :bold)
    end

    # pdf.table([ [billing_details, invoice_details] ], cell_style: {padding: 0}) do
    pdf.table([ [invoice_details] ], cell_style: {padding: 0}) do
      row(0..10).style(borders: [])
    end
  end

  # Renders details of invoice in a tabular format. Renders each line item, and
  # unit price, and total amount, along with tax. It also displays summary,
  # ie total amount, and total price along with tax.
  def render_summary(pdf)
    pdf.move_down 25
    pdf.text 'Invoice Summary', size: 12, style: :bold
    pdf.stroke_horizontal_rule

    table_details = [ ['Product', 'Qty', 'Price', 'Amount'] ]
    invoice.line_items.each_with_index do |line_item|
      # table_details << [line_item.product.print_name]
      # table_details << [line_item.quantity_out, line_item.product.selling_price, line_item.amount]
      table_details << [line_item.product.print_name, line_item.quantity_out, line_item.product.selling_price, line_item.amount]
    end
    pdf.table(table_details, column_widths: [40, 380, 60, 60], header: true,
              cell_style: {padding: 5, border_width: 0.5}) do
      row(0).style(size: 10, font_style: :bold)
      row(0..100).style(size: 9)

      cells.columns(0).align = :right
      cells.columns(2).align = :right
      cells.columns(3).align = :right
      row(0..100).borders = [:top, :bottom]
    end

    summary_details = [
      # ['Subtotal', invoice.amount],
      # ['Tax',      invoice.tax_amount_formatted],
      ['Total',    invoice.amount]
    ]
    pdf.table(summary_details, column_widths: [480, 60], header: true,
              cell_style: {padding: 5, border_width: 0.5}) do
      row(0..100).style(size: 9, font_style: :bold)
      row(0..100).borders = []
      cells.columns(0..100).align = :right
    end

    pdf.move_down 25
    pdf.stroke_horizontal_rule
  end
end
