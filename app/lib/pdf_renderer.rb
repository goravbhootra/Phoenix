# The PDF renderer. We use this internally in Payday to render pdfs, but really you should just need to call
# {{Payday::Invoiceable#render_pdf}} to render pdfs yourself.
class PdfRenderer
  # Renders the given invoice as a pdf on disk
  def self.render_to_file(invoice, path)
    pdf(invoice).render_file(path)
  end

  # Renders the given invoice as a pdf, returning a string
  def self.render(invoice)
    pdf(invoice).render
  end

  private

  def self.pdf(invoice)
    # pdf = Prawn::Document.new(page_size: invoice_or_default(invoice, :page_size))
    pdf = Prawn::Document.new

    # set up some default styling
    pdf.font_size(8)

    # stamp(invoice, pdf)
    # company_banner(invoice, pdf)
    # bill_to_ship_to(invoice, pdf)
    invoice_details(invoice, pdf)
    line_items_table(invoice, pdf)
    totals_lines(invoice, pdf)
    # notes(invoice, pdf)

    # page_numbers(pdf)

    pdf
  end

  def self.stamp(invoice, pdf)
    # stamp = nil
    # if invoice.refunded?
    #   stamp = I18n.t "payday.status.refunded", default: "REFUNDED"
    # elsif invoice.paid?
    #   stamp = I18n.t "payday.status.paid", default: "PAID"
    # elsif invoice.overdue?
    #   stamp = I18n.t "payday.status.overdue", default: "OVERDUE"
    # end

    # if stamp
    #   pdf.bounding_box([150, pdf.cursor - 50], width: pdf.bounds.width - 300) do
    #     pdf.font("Helvetica-Bold") do
    #       pdf.fill_color "cc0000"
    #       pdf.text stamp, align: :center, size: 25, rotate: 15
    #     end
    #   end
    # end

    # pdf.fill_color "000000"
  end

  def self.company_banner(invoice, pdf)
    # render the logo
    image = invoice_or_default(invoice, :invoice_logo)
    height = nil
    width = nil

    # Handle images defined with a hash of options
    if image.is_a?(Hash)
      data = image
      image = data[:filename]
      width, height = data[:size].split("x").map(&:to_f)
    end

    if File.extname(image) == ".svg"
      logo_info = pdf.svg(File.read(image), at: pdf.bounds.top_left, width: width, height: height)
      logo_height = logo_info[:height]
    else
      logo_info = pdf.image(image, at: pdf.bounds.top_left, width: width, height: height)
      logo_height = logo_info.scaled_height
    end

    # render the company details
    table_data = []
    table_data << [bold_cell(pdf, invoice_or_default(invoice, :company_name).strip, size: 12)]

    invoice_or_default(invoice, :company_details).lines.each { |line| table_data << [line] }

    table = pdf.make_table(table_data, cell_style: { borders: [], padding: 0 })
    pdf.bounding_box([pdf.bounds.width - table.width, pdf.bounds.top], width: table.width, height: table.height + 5) do
      table.draw
    end

    pdf.move_cursor_to(pdf.bounds.top - logo_height - 20)
  end

  def self.bill_to_ship_to(invoice, pdf)
    bill_to_cell_style = { borders: [], padding: [2, 0] }
    bill_to_ship_to_bottom = 0

    # render bill to
    pdf.float do
      table = pdf.table([[bold_cell(pdf, I18n.t("payday.invoice.bill_to", default: "Bill To"))],
                         [invoice.bill_to]], column_widths: [200], cell_style: bill_to_cell_style)
      bill_to_ship_to_bottom = pdf.cursor
    end

    # render ship to
    if defined?(invoice.ship_to) && !invoice.ship_to.nil?
      table = pdf.make_table([[bold_cell(pdf, I18n.t("payday.invoice.ship_to", default: "Ship To"))],
                              [invoice.ship_to]], column_widths: [200], cell_style: bill_to_cell_style)

      pdf.bounding_box([pdf.bounds.width - table.width, pdf.cursor], width: table.width, height: table.height + 2) do
        table.draw
      end
    end

    # make sure we start at the lower of the bill_to or ship_to details
    bill_to_ship_to_bottom = pdf.cursor if pdf.cursor < bill_to_ship_to_bottom
    pdf.move_cursor_to(bill_to_ship_to_bottom - 20)
  end

  def self.invoice_details(invoice, pdf)
    # invoice details
    table_data = []

    # invoice number
    if defined?(invoice.number) && invoice.number
      table_data << [bold_cell(pdf, I18n.t("payday.invoice.invoice_no", default: "Invoice #:")), bold_cell(pdf, invoice.invoice_number.to_s, align: :right)]
    end

    # invoice date
    if defined?(invoice.invoice_date) && invoice.invoice_date
      if invoice.invoice_date.is_a?(Date) || invoice.invoice_date.is_a?(Time)
        invoice_date = invoice.invoice_date.strftime(Payday::Config.default.date_format)
      else
        invoice_date = invoice.invoice_date.to_s
      end

      table_data << [bold_cell(pdf, I18n.t("payday.invoice.invoice_date", default: "Invoice Date:")),
                     bold_cell(pdf, invoice_date, align: :right)]
    end

    # Due on
    if defined?(invoice.due_at) && invoice.due_at
      if invoice.due_at.is_a?(Date) || invoice.due_at.is_a?(Time)
        due_date = invoice.due_at.strftime(Payday::Config.default.date_format)
      else
        due_date = invoice.due_at.to_s
      end

      table_data << [bold_cell(pdf, I18n.t("payday.invoice.due_date", default: "Due Date:")),
                     bold_cell(pdf, due_date, align: :right)]
    end

    # Paid on
    if defined?(invoice.paid_at) && invoice.paid_at
      if invoice.paid_at.is_a?(Date) || invoice.paid_at.is_a?(Time)
        paid_date = invoice.paid_at.strftime(Payday::Config.default.date_format)
      else
        paid_date = invoice.paid_at.to_s
      end

      table_data << [bold_cell(pdf, I18n.t("payday.invoice.paid_date", default: "Paid Date:")),
                     bold_cell(pdf, paid_date, align: :right)]
    end

    # Refunded on
    if defined?(invoice.refunded_at) && invoice.refunded_at
      if invoice.refunded_at.is_a?(Date) || invoice.refunded_at.is_a?(Time)
        refunded_date = invoice.refunded_at.strftime(Payday::Config.default.date_format)
      else
        refunded_date = invoice.refunded_at.to_s
      end

      table_data << [bold_cell(pdf, I18n.t("payday.invoice.refunded_date", default: "Refunded Date:")),
                     bold_cell(pdf, refunded_date, align: :right)]
    end

    # loop through invoice_details and include them
    # invoice.each_detail do |key, value|
    #   table_data << [bold_cell(pdf, key),
    #                  bold_cell(pdf, value, align: :right)]
    # end

    if table_data.length > 0
      pdf.table(table_data, cell_style: { borders: [], padding: [1, 10, 1, 1] })
    end
  end

  def self.line_items_table(invoice, pdf)
    table_data = []
    table_data << [bold_cell(pdf, I18n.t("payday.line_item.description", default: "Description"), borders: []),
                   bold_cell(pdf, I18n.t("payday.line_item.unit_price", default: "Unit Price"), align: :center, borders: []),
                   bold_cell(pdf, I18n.t("payday.line_item.quantity", default: "Quantity"), align: :center, borders: []),
                   bold_cell(pdf, I18n.t("payday.line_item.amount", default: "Amount"), align: :center, borders: [])]
    invoice.line_items.each do |line|
      table_data << [line.description, line.selling_price, line.quantity, line.amount]
    end

    pdf.move_cursor_to(pdf.cursor - 20)
    pdf.table(table_data, width: pdf.bounds.width, header: true,
              cell_style: { border_width: 0.5, border_color: "cccccc",
                            padding: [5, 10] },
              row_colors: %w(dfdfdf ffffff)) do

      # left align the number columns
      columns(1..3).rows(1..row_length - 1).style(align: :right)

      # set the column widths correctly
      natural = natural_column_widths
      natural[0] = width - natural[1] - natural[2] - natural[3]

      column_widths = natural
    end
  end

  def self.totals_lines(invoice, pdf)
    table_data = []
    # table_data << [
    #   bold_cell(pdf, I18n.t("payday.invoice.subtotal", default: "Subtotal:")),
    #   cell(pdf, number_to_currency(invoice.subtotal, invoice), align: :right)
    # ]

    # if invoice.tax_rate > 0
    #   if invoice.tax_description.nil?
    #     tax_description = I18n.t("payday.invoice.tax", default: "Tax:")
    #   else
    #     tax_description = invoice.tax_description
    #   end

    #   table_data << [
    #     bold_cell(pdf, tax_description),
    #     cell(pdf, number_to_currency(invoice.tax, invoice), align: :right)
    #   ]
    # end
    # if invoice.shipping_rate > 0
    #   if invoice.shipping_description.nil?
    #     shipping_description =
    #       I18n.t("payday.invoice.shipping", default: "Shipping:")
    #   else
    #     shipping_description = invoice.shipping_description
    #   end

    #   table_data << [
    #     bold_cell(pdf, shipping_description),
    #     cell(pdf, number_to_currency(invoice.shipping, invoice),
    #          align: :right)
    #   ]
    # end
    table_data << [
      # bold_cell(pdf, I18n.t("payday.invoice.total", default: "Total:"), size: 8),
      bold_cell(pdf, 'Total Amount:', size: 8),
      # cell(pdf, number_to_currency(invoice.total, invoice),
      cell(pdf, invoice.amount, size: 8, align: :right)
    ]
    table = pdf.make_table(table_data, cell_style: { borders: [] })
    pdf.bounding_box([pdf.bounds.width - table.width, pdf.cursor],
                     width: table.width, height: table.height + 2) do

      table.draw
    end
  end

  def self.notes(invoice, pdf)
    if defined?(invoice.notes) && invoice.notes
      pdf.move_cursor_to(pdf.cursor - 30)
      pdf.font("Helvetica-Bold") do
        pdf.text(I18n.t("payday.invoice.notes", default: "Notes"))
      end
      pdf.line_width = 0.5
      pdf.stroke_color = "cccccc"
      pdf.stroke_line([0, pdf.cursor - 3, pdf.bounds.width, pdf.cursor - 3])
      pdf.move_cursor_to(pdf.cursor - 10)
      pdf.text(invoice.notes.to_s)
    end
  end

  def self.page_numbers(pdf)
    if pdf.page_count > 1
      pdf.number_pages("<page> / <total>", at: [pdf.bounds.right - 18, -15])
    end
  end

  def self.invoice_or_default(invoice, property)
    if invoice.respond_to?(property) && invoice.send(property)
      invoice.send(property)
    else
      # Config.default.send(property)
      "LETTER"
    end
  end

  def self.cell(pdf, text, options = {})
    Prawn::Table::Cell::Text.make(pdf, text, options)
  end

  def self.bold_cell(pdf, text, options = {})
    cell(pdf, "<b>#{text}</b>", options.merge(inline_format: true))
  end

  # Converts this number to a formatted currency string
  def self.number_to_currency(number, invoice)
    currency = Money::Currency.wrap(invoice_or_default(invoice, :currency))
    number *= currency.subunit_to_unit
    number = number.round unless Money.infinite_precision
    Money.new(number, currency).format
  end

  def self.max_cell_width(cell_proxy)
    max = 0
    cell_proxy.each do |cell|
      max = cell.natural_content_width if cell.natural_content_width > max
    end

    max
  end
end
