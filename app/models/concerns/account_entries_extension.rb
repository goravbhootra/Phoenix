module AccountEntriesExtension
  def balance
    reject(&:marked_for_destruction?).sum(&:amount)
  end

  def account_types
    account_ids = collect(&:account_id).uniq
    Account.return_types(account_ids)
  end
end
