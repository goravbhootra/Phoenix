class PaymentCollectionReportPdf < Prawn::Document
  def initialize
    super({top_margin: 40, left_margin: 50, right_margin: 50, bottom_margin: 20})
    @users_with_balance_due = (User.where.not(cash_account_id: nil).select { |user| user.cash_account.entries.debit_balance != 0 })
    text "Spiritual Hierarchy Publication Trust", size: 16, style: :bold, align: :center
    text "Chennai Bookstall - Collection report", size: 13, align: :center
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
