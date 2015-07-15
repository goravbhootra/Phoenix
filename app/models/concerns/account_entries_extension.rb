module AccountEntriesExtension
  def total_amount
    reject(&:marked_for_destruction?).sum(&:amount)
  end

  def account_types
    account_ids = collect(&:account_id).uniq
    Account.return_types(account_ids)
  end

  def payments
    account_types_hash = account_types
    reject(&:marked_for_destruction?).select { |x| ['Account::CashAccount', 'Account::BankAccount'].include? (account_types_hash[x.account_id]) }
  end
end
