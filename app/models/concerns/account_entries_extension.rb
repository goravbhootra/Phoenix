module AccountEntriesExtension
  def debit_balance
    where(type: 'AccountEntry::Debit').sum(:amount) - where(type: 'AccountEntry::Credit').sum(:amount)
  end

  def total_amount
    reject(&:marked_for_destruction?).sum(&:amount)
  end

  def sales_entries
    reject(&:marked_for_destruction?).select { |x| is_sales_entry?(x.mode) }
  end

  def sales_total_amount
    sales_entries.sum(&:amount)
  end

  # def account_types
  #   hsh = Hash.new
  #   reject(&:marked_for_destruction?).map { |entry| hsh[entry.account_id] = entry.mode }
  #   hsh
  # end

  # Returns ActiveRecord set
  def payment_entries
    reject(&:marked_for_destruction?).select { |x| is_payment?(x.mode) }
  end

  # Returns Hash
  def payment_account_types
    hsh = Hash.new
    payment_entries.map { |entry| hsh[entry.account_id] = entry.mode }
    hsh
  end

  def payment_account_types_humanize
    hsh = Hash.new
    payment_entries.each do |payment|
      hsh[payment.account_id] = 'Cash' and next if payment.mode == 'Account::CashAccount'
      hsh[payment.account_id] = 'Credit Card' and next if payment.mode == 'Account::BankAccount'
    end
    hsh
  end

  # def payments_type_with_account_type
  #   arr = reject(&:marked_for_destruction?).map { |x| [x.type, x.mode] if is_payment?(x.mode) }.compact
  #   hsh = Hash.new
  #   arr.each { |x| hsh.keys.include?(x[0].to_s) ? hsh[x[0].to_s] << x[1] : hsh[x[0].to_s] = Array(x[1]) }
  #   hsh
  # end

  def is_payment?(account_type=nil)
    ['Account::CashAccount', 'Account::BankAccount'].include? account_type
  end

  def is_sales_entry?(account_type=nil)
    ['Account::SalesAccount'].include? account_type
  end
end
