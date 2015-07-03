class PosInvoice < Invoice

  validates :customer_membership_number, length: { is: 9 }, allow_nil: true, allow_blank: true

  before_validation :consolidate_payments_on_mode
  before_validation :invoice_amount_and_payment_reconciliation

  def set_defaults
    # self.primary_location_id = 150 if self.primary_location_id.blank? # Chennai Bookstall
    self.secondary_entity_id = 105 if self.secondary_entity_id.blank?
    self.voucher_sequence_id = 6 if self.voucher_sequence_id.blank? # Chennai POS
    self.goods_value = self.total_amount if self.goods_value.blank?
  end

  def process_calculations
    VoucherCalculations.new({voucher: self, quantity_field: 'quantity'}).process_invoice_out_totals
    errors.add(:base, 'No products added! Total amount should be more than 0') and return false if self.total_amount < 1
    self.goods_value = self.total_amount
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
    if attributed['mode_id'].blank? || attributed['amount'].to_i < 1
      # handle new records with invalid data
      return true if attributed['id'].blank?

      # handle existing records with invalid data
      attributed['_destroy'] = true if attributed['id'].present?
    end

    if attributed['mode_id'] == '2'
      attributed['additional_details'] = {
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

  def consolidate_line_items_on_product
    VoucherConsolidateLineItems.new({voucher: self, association_name: 'line_items', attrib_id: 'product_id', consolidate: 'quantity'}).consolidate_with_same_attribute
  end

  def payment_checks_and_credit_card_info
    payments.each do |payment|
      # Invoice Payment received by
      payment['received_by_id'] = payment['received_by_id'].presence || current_user_id

      if payment['mode_id'] == 5 && BigDecimal(payment['amount']) > BigDecimal('0')
        payment['amount'] = BigDecimal("-#{payment['amount']}")
      else
        payment['amount'] = BigDecimal("#{payment['amount']}")
      end

      # errors.add(:mode_id, 'Credit card details invalid or incomplete') and return false if payment['mode_id'] == 2 && (payment['additional_details']['bank_name'].blank? || payment['additional_details']['card_last_digits'].blank? || payment['additional_details']['expiry_month'].blank? || payment['additional_details']['expiry_year'].blank? || payment['additional_details']['mobile_number'].blank? || payment['additional_details']['card_holder_name'].blank?)
    end
  end

  def consolidate_payments_on_mode
    VoucherConsolidateLineItems.new({voucher: self, association_name: 'payments', attrib_id: 'mode_id', consolidate: 'amount'}).consolidate_with_same_attribute
  end

  def invoice_amount_and_payment_reconciliation
    invoice_amount = line_items.reject(&:marked_for_destruction?).sum(&:amount)
    net_payment = payments.reject(&:marked_for_destruction?).sum(&:amount)
    puts "invoice_amount: #{invoice_amount}, net_payment: #{net_payment}"
    errors.add(:base, 'Bill amount and payment do not reconcile! Please check the details') and return false unless invoice_amount == net_payment
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
              if payment.additional_details.present?
                pmt['card_last_digits'] = payment.additional_details['card_last_digits']
                pmt['bank_name'] = payment.additional_details['bank_name']
                pmt['card_holder_name'] = payment.additional_details['card_holder_name']
                pmt['mobile_number'] = payment.additional_details['mobile_number']
                pmt['expiry_month'] = payment.additional_details['expiry_month'].present? ? "#{payment.additional_details['expiry_month']}/" : ''
                pmt['expiry_year'] = payment.additional_details['expiry_year']
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
end
