class PosInvoice < Invoice

  validates :bank_name, :card_last_digits, :expiry_month, :expiry_year, :mobile_number, :card_holder_name, presence: true
  ### defined in account_txn.rb ###
  def has_credit_entries?
    errors[:base] << 'No products added! Total amount should be more than 0' if self.credit_entries.blank? || credit_entries.total_amount <= 0
  end

  def has_debit_entries?
    errors[:base] << 'Payment detail needs to be entered against the invoice' if self.debit_entries.blank? || debit_entries.total_amount <= 0
  end

  def entries_cancel?
    errors[:base] << 'Payment is not equal to Invoice amount' if credit_entries.total_amount != debit_entries.total_amount
  end
  ### end of defined in account_txn.rb ###

  def entries_account_types
    account_types = entries.account_types
  end

  ### defined in invoice.rb ###
  def create_sales_entry
    total = VoucherCalculations.new({voucher: self, quantity_field: 'quantity'}).calculate_invoice_total
    credit_entries.clear
    credit_entries.build(amount: total, account_id: current_location.sales_account_id)
  end

  def convert_quantity_to_negative
    self.line_items.reject(&:marked_for_destruction?).each { |x| x.quantity = -x.quantity if x.quantity > 0 }
  end

  def mandatory_values_check(attributed)
    if attributed['product_id'].blank? || attributed['quantity'].to_i < 1
      # handle new records with invalid data
      return true if attributed['id'].blank?

      # handle existing records with invalid data
      attributed['_destroy'] = true if attributed['id'].present?
    end
    false
  end

  def payment_mandatory_values_check(attributed)
    if attributed['account_id'].blank? || attributed['amount'].to_i < 1
      # handle new records with invalid data
      return true if attributed['id'].blank?

      # handle existing records with invalid data
      attributed['_destroy'] = true if attributed['id'].present?
    end

    if @account_types[attributed['mode_id'].to_i] == 'Account::BankAccount'
      attributed['additional_info'] = {
                                    bank_name: attributed['bank_name'],
                                    card_last_digits: attributed['card_last_digits'],
                                    expiry_month: attributed['expiry_month'],
                                    expiry_year: attributed['expiry_year'],
                                    mobile_number: attributed['mobile_number'],
                                    card_holder_name: attributed['card_holder_name']
                                  }
    end
    false
  end
  ### end of defined in invoice.rb ###

  ### not used in new structure - to be deleted ###
  def payment_checks_and_credit_card_info
    payments.each do |payment|
      # errors.add(:mode_id, 'Credit card details invalid or incomplete') and return false if payment['mode_id'] == 2 && (payment['additional_info']['bank_name'].blank? || payment['additional_info']['card_last_digits'].blank? || payment['additional_info']['expiry_month'].blank? || payment['additional_info']['expiry_year'].blank? || payment['additional_info']['mobile_number'].blank? || payment['additional_info']['card_holder_name'].blank?)
    end
  end

  def self.payments_to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ['invoice_date', 'invoice_number', 'total_amount', 'pmt_cash', 'pmt_credit_card',
              'created_by', 'card_last_digits', 'bank_name', 'card_holder_name', 'abhyasi_mobile', 'card_expiry', 'created_at', 'updated_at']
      pmt = Hash.new
      PosInvoice.find_each do |invoice|
        cash = 0
        credit_card = 0
        pmt['card_last_digits'] = pmt['bank_name'] = pmt['card_holder_name'] = ''
        pmt['mobile_number'] = pmt['expiry_month'] = pmt['expiry_year'] = ''
        invoice.payments.each do |payment|
          case payment.mode_id
            when 1
              cash += payment.amount
            when 2
              credit_card += payment.amount
              if payment.additional_info.present?
                pmt['card_last_digits'] = payment.additional_info['card_last_digits']
                pmt['bank_name'] = payment.additional_info['bank_name']
                pmt['card_holder_name'] = payment.additional_info['card_holder_name']
                pmt['mobile_number'] = payment.additional_info['mobile_number']
                pmt['expiry_month'] = payment.additional_info['expiry_month'].present? ? "#{payment.additional_info['expiry_month']}/" : ''
                pmt['expiry_year'] = payment.additional_info['expiry_year']
              end
            when 5
              cash += payment.amount
          end
        end
        csv << [
                  invoice.invoice_date.strftime('%d/%m/%Y'), invoice.number,
                  invoice.total_amount, cash, credit_card, invoice.created_by_name,
                  pmt['card_last_digits'], pmt['bank_name'], pmt['card_holder_name'],
                  pmt['mobile_number'], "#{pmt['expiry_month']}#{pmt['expiry_year']}",
                  invoice.created_at, invoice.updated_at
                ]
      end
    end
  end

  def self.rows_for_export
    product_ids = InvoiceLineItem.pluck(:product_id).uniq
    product_details = product_details_by_ids(product_ids)

    result = []
    find_each do |invoice|
      invoice.line_items.each do |line_item|
        result << [
                invoice.invoice_date.strftime('%d/%m/%Y'),
                invoice.number,
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
    result
  end
  ### end of not used in new structure - to be deleted ###
end
