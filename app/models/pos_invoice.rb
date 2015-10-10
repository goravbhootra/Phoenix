class PosInvoice < Invoice

  # validates :bank_name, :card_last_digits, :expiry_month, :expiry_year, :mobile_number, :card_holder_name, presence: true
  def entries_account_types
    account_types = entries.account_types
  end

  def destroy_with_children
    ActiveRecord::Base.transaction do
      self.entries.destroy_all
      self.debit_entries.destroy_all
      self.credit_entries.destroy_all
      self.header.destroy
      self.line_items.destroy_all
      self.destroy!
    end
  end

  ### defined in invoice.rb ###
  def payment_mandatory_values_check(attributed)
    if attributed['account_id'].blank? || attributed['amount'].to_i < 1
      # handle new records with invalid data
      return true if attributed['id'].blank?

      # handle existing records with invalid data
      attributed['_destroy'] = true if attributed['id'].present?
    end

    if (attributed['_destroy'].blank? || attributed['_destroy'] == '0' || attributed['_destroy'] == 'false') && Account.find(attributed['account_id'].to_i).type == 'Account::BankAccount'
      attributed['additional_info'] ||= Hash.new
      attributed['additional_info']['bank_name'] = attributed['bank_name']
      attributed['additional_info']['card_last_digits'] = attributed['card_last_digits']
      attributed['additional_info']['expiry_month'] = attributed['expiry_month']
      attributed['additional_info']['expiry_year'] = attributed['expiry_year']
      attributed['additional_info']['mobile_number'] = attributed['mobile_number']
      attributed['additional_info']['card_holder_name'] = attributed['card_holder_name']
    end
    false
  end
  ### end of defined in invoice.rb ###
end
