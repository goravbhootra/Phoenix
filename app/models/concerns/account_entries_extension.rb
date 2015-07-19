module AccountEntriesExtension
  def total_amount
    reject(&:marked_for_destruction?).sum(&:amount)
  end

  def account_types
    account_ids = reject(&:marked_for_destruction?).collect(&:account_id).uniq
    Account.return_types(account_ids)
  end

  def payment_account_types
    account_types_hash = account_types
    account_types_hash.keys.each { |x| account_types_hash.delete(x) if !is_payment?(account_types_hash[x]) }
    account_types_hash
  end

  def payment_account_types_humanize
    ath = payment_account_types
    ath.keys.each do |key|
      ath[key] = 'Cash' and next if ath[key] == 'Account::CashAccount'
      ath[key] = 'Credit Card' and next if ath[key] == 'Account::BankAccount'
    end
    ath
  end

  def payments_type_with_account_type
    account_types_hash = account_types
    arr = reject(&:marked_for_destruction?).map { |x| [x.type, account_types_hash[x.account_id]] if is_payment?(account_types_hash[x.account_id]) }.compact
    hash = Hash.new
    arr.each { |x| hash.keys.include?(x[0].to_s) ? hash[x[0].to_s] << x[1] : hash[x[0].to_s] = Array(x[1]) }
    hash
  end

  def is_payment?(account_type=nil)
    ['Account::CashAccount', 'Account::BankAccount'].include? account_type
  end

  def payments
    account_types_hash = account_types
    reject(&:marked_for_destruction?).select {|x| is_payment?(account_types_hash[x.account_id])}
  end
end
