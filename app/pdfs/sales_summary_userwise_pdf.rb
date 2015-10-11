class SalesSummaryUserwisePdf < Prawn::Document
  def initialize
    super({top_margin: 40, left_margin: 50, right_margin: 50, bottom_margin: 20})

    # Returns Hash with (k) - user_id, (v) - amount
    @userwise_sales_consolidated = InvoiceLineItem.joins(account_txn: [:header, :created_by]).where(account_txn_id: InvoiceHeader.where(business_entity_location_id: GlobalSettings.current_bookstall_id).pluck(:account_txn_id)).group(:created_by_id).sum(:amount)

    pos_cash_collected = AccountEntry::Debit.where(account_txn_id: InvoiceHeader.where(business_entity_location_id: GlobalSettings.current_bookstall_id).pluck(:account_txn_id)).joins(:account).where("accounts.type = 'Account::CashAccount'").sum(:amount)
    pos_cash_tendered = AccountEntry::Credit.where(account_txn_id: InvoiceHeader.where(business_entity_location_id: GlobalSettings.current_bookstall_id).pluck(:account_txn_id)).joins(:account).where("accounts.type = 'Account::CashAccount'").sum(:amount)
    @pos_cash_sales = (pos_cash_collected - pos_cash_tendered).to_f

    @pos_credit_card_sales = AccountEntry::Debit.where(account_txn_id: InvoiceHeader.where(business_entity_location_id: GlobalSettings.current_bookstall_id).pluck(:account_txn_id)).joins(:account).where("accounts.type = 'Account::BankAccount'").sum(:amount)

    @users_with_balance_due = (User.includes(:cash_account).where.not(cash_account_id: nil).select { |user| user.cash_account.entries.debit_balance != 0 })
    text GlobalSettings.organisation_name, size: 16, style: :bold, align: :center
    text "Collection report", size: 13, align: :center
    stroke_horizontal_rule
    move_down 10
    text "Summary of payments received on #{ Time.zone.now.to_date }", size: 12
    move_down 5
    text "Generated at: #{ Time.zone.now.to_formatted_s(:long) }", size: 12
    line_items
  end

  def line_items
    move_down 10
    table line_item_rows do
      row(0).font_style = :bold
      row(0).align = :center
      columns(0).align = :center
      columns(1).align = :left
      columns(2).align = :right
      self.row_colors = ["DDDDDD", "FFFFFF"]
      self.width = 500
      self.cell_style = { size: 12, padding_left: 20, padding_right: 20 }
      self.header = true
    end
  end

  def line_item_rows
    result = Array.new
    result << ['ID #', "Name", "Cash Amount Due"]
    @users_with_balance_due.each do |user|
      result << [user.membership_number, user.name, "#{sprintf '%.0f', user.cash_account.entries.debit_balance}"]
    end
    result
  end
end
