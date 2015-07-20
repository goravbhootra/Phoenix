class PosInvoicePdf < Prawn::Document
  def initialize(pos_invoice)
    super({top_margin: 10, left_margin: 5, right_margin: 5, bottom_margin: 100})
    text "Spiritual Hierarchy Publication Trust", size: 30, style: :bold, align: :center
    # text "Near IIM, Sitapur-Hardoi Bypass Road, Lucknow-226013", size: 20, align: :center
    text "Babuji Memorial Ashram, Manapakkam, Chennai", size: 20, align: :center
    text 'TIN# 33400845081', size: 25, align: :center
    stroke_horizontal_rule
    @pos_invoice = pos_invoice
    pos_invoice_number
    line_items
    total_amount
  end

  def pos_invoice_number
    move_down 20
    text "POS Invoice \##{@pos_invoice.number}", size: 25, style: :bold, align: :center
    move_down 10
    text "Dated: #{@pos_invoice.txn_date.strftime('%d/%m/%Y')}", size: 20
  end

  def line_items
    move_down 10
    table line_item_rows do
      row(0).font_style = :bold
      columns(0).align = :center
      columns(0).width = 85
      columns(1).align = :left
      columns(1).width = 235
      columns(2..3).align = :center
      columns(2).width = 75
      columns(3).width = 90
      column(4).align = :right
      columns(4).width = 115
      row(0).align = :center
      # self.row_colors = ["DDDDDD", "FFFFFF"]
      self.width = 600
      self.cell_style = { size: 20, padding_left: 20, padding_right: 20 }
      self.header = true
    end
  end

  def line_item_rows
    result = [['SKU', "Product", "Qty", "Price", "Amount"]]
    @pos_invoice.line_items.map do |item|
      next if !item.persisted?
      result += [[item.product.sku, item.voucher_print_name, -item.quantity, (sprintf '%.0f', item.selling_price), (sprintf '%.0f', item.amount)]]
    end
    result
  end

  def total_amount
    move_down 25
    indent(290) do
      text "Total Amount: #{(sprintf '%.2f', @pos_invoice.credit_entries.sales_total_amount)}", size: 25, style: :bold
      text "Total Quantity: #{@pos_invoice.total_quantity}", size: 25
    end
    move_down 15
    text 'Payment Details:', size: 22, style: :bold
    indent(20) do
      @pos_invoice.payments.each do |payment|
        next if payment.new_record?
        account_types = @pos_invoice.entries_account_types
        text (payment.type == 'AccountEntry::Debit' ? "Cash: #{(sprintf '%.2f', payment.amount)}" : "Cash Tendered: #{(sprintf '%.2f', payment.amount)}"), size: 20 if account_types[payment.account_id] == 'Account::CashAccount'
        if account_types[payment.account_id] == 'Account::BankAccount' && payment.additional_info.present?
          indent(20) do
            text "Bank Name: #{payment.additional_info['bank_name']}", size: 18
            text "Card last 4 digits: #{payment.additional_info['card_last_digits']}", size: 18
            text "Expiry month/year: #{payment.additional_info['expiry_month']} / #{payment.additional_info['expiry_year']}", size: 18
            text "Mobile Number: #{payment.additional_info['mobile_number']}", size: 18
            text "Card Holder's Name: #{payment.additional_info['card_holder_name']}", size: 18
          end
        end
        move_down 10
      end
    end
    text "You were served by: #{@pos_invoice.created_by.name}", size: 20
    move_down 5
    text "Prices are inclusive of taxes", size: 20
    move_down 50
  end
end
