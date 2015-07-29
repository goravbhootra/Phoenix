class PosInvoiceReport < ActiveType::Object

  def self.invoice_list_with_payments_to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ['invoice_date', 'invoice_number', '# of line items', '# of products', 'total_amount', 'pmt_cash', 'pmt_credit_card',
              'created_by', 'card_last_digits', 'bank_name', 'card_holder_name', 'abhyasi_mobile', 'card_expiry', 'created_at', 'updated_at']
      pmt = Hash.new
      PosInvoice.includes(:header, [entries: :account], :line_items, :created_by).where("invoice_headers.business_entity_location_id = 154").references("invoice_headers").order(:txn_date, :number).find_each(batch_size: 750) do |invoice|
        pmt['credit_card'] = pmt['cash'] = pmt['card_last_digits'] = pmt['bank_name'] = pmt['card_holder_name'] = ''
        pmt['mobile_number'] = pmt['expiry_month'] = pmt['expiry_year'] = ''
        invoice.entries.each do |entry|
          case entry.type
          when 'AccountEntry::Debit'
            case entry.account.type
            when 'Account::CashAccount'
              pmt['cash'] = pmt['cash'].to_i + entry.amount
            when 'Account::BankAccount'
              pmt['credit_card'] = pmt['credit_card'].to_i + entry.amount
              if entry.additional_info.present?
                pmt['card_last_digits'] = entry.additional_info['card_last_digits']
                pmt['bank_name'] = entry.additional_info['bank_name']
                pmt['card_holder_name'] = entry.additional_info['card_holder_name']
                pmt['mobile_number'] = entry.additional_info['mobile_number']
                pmt['expiry_month'] = entry.additional_info['expiry_month'].present? ? "#{entry.additional_info['expiry_month']}/" : ''
                pmt['expiry_year'] = entry.additional_info['expiry_year']
              end
            end
          when 'AccountEntry::Credit'
            case entry.account.type
            when 'Account::CashAccount'
              pmt['cash'] = pmt['cash'].to_i - entry.amount
            end
          end
        end

        csv << [
                  invoice.txn_date.strftime('%d/%m/%Y'),
                  "#{invoice.number_prefix} #{invoice.number}",
                  invoice.line_items.size,
                  invoice.line_items.total_quantity,
                  invoice.line_items.total_amount,
                  pmt['cash'],
                  pmt['credit_card'],
                  invoice.created_by_name,
                  pmt['card_last_digits'], pmt['bank_name'], pmt['card_holder_name'],
                  pmt['mobile_number'], "#{pmt['expiry_month']}#{pmt['expiry_year']}",
                  invoice.created_at, invoice.updated_at
                ]
      end
    end
  end

  def self.pos_invoice_line_items_to_csv(options = {})
    # Chennai Business Entity - Tiruvallur Location
    account_txn_ids = InvoiceHeader.where(business_entity_location_id: 154).pluck(:account_txn_id)
    product_ids = InvoiceLineItem.where(account_txn_id: account_txn_ids).pluck(:product_id).uniq
    product_details = Product.product_details_by_ids(product_ids)

    CSV.generate(options) do |csv|
      csv << ['Invoice Date', 'Invoice Number', 'SKU', 'Product Name', 'Category Code', 'Language Code', 'Quantity', 'Price', 'Amount', 'Created At', 'Updated At']

      InvoiceLineItem.includes(:account_txn).where(account_txn_id: account_txn_ids).order("account_txns.txn_date, account_txns.number").find_each do |line_item|
        csv << [
          line_item.account_txn.txn_date.strftime('%d/%m/%Y'),
          line_item.account_txn.number,
          product_details[line_item.product_id][:sku],
          product_details[line_item.product_id][:name],
          product_details[line_item.product_id][:category_code],
          product_details[line_item.product_id][:language_code],
          -line_item.quantity,
          line_item.price,
          line_item.amount,
          line_item.updated_at,
          line_item.created_at
        ]
      end
    end
  end
end
