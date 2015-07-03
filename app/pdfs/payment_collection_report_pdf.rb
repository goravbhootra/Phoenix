class PaymentCollectionReportPdf < Prawn::Document
  def initialize(pos_invoice_payments)
    super({top_margin: 25, left_margin: 20, right_margin: 15, bottom_margin: 20})
    text "Spiritual Hierarchy Publication Trust", size: 16, style: :bold, align: :center
    text "Chennai Bookstall - Sales Collection report", size: 13, align: :center
    stroke_horizontal_rule
    @pos_invoice_payments = pos_invoice_payments
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
      columns(0).align = :center
      columns(1).align = :left
      columns(2..4).align = :right
      row(0).align = :center
      row(-1).font_style = :bold
      self.row_colors = ["DDDDDD", "FFFFFF"]
      self.width = 570
      self.cell_style = { size: 12, padding_left: 20, padding_right: 20 }
      self.header = true
    end
  end

  def line_item_rows
    collection_hash = {}
    @pos_invoice_payments.all.each do |payment|
      collection_hash[payment.received_by_id] = {} if collection_hash.keys.exclude?(payment.received_by_id)
      if collection_hash[payment.received_by_id].keys.include?("#{payment.mode_id}")
        collection_hash[payment.received_by_id]["#{payment.mode_id}"] += payment.amount
      else
        collection_hash[payment.received_by_id]["#{payment.mode_id}"] = payment.amount
      end
    end
    collection_hash.each do |k,v|
      next if collection_hash[k].blank?
      if collection_hash[k].keys.include?('5') && collection_hash[k].keys.include?('1')
        collection_hash[k]['1'] += collection_hash[k]['5']
        collection_hash[k].delete('5')
      elsif collection_hash[k].keys.include?('5')
        collection_hash[k]['1'] = collection_hash[k]['5']
        collection_hash[k].delete('5')
      end
    end

    total_collection = Hash.new
    total_collection['cash'] = 0
    total_collection['credit_card'] = 0
    result = Array.new
    collection_hash.keys.each do |key|
      user = User.find(key)
      result += [[user.membership_number, user.name, "%.2f"%collection_hash[key]['1'].to_f, "%.2f"%collection_hash[key]['2'].to_f, "%.2f"%(collection_hash[key]['1'].to_f+collection_hash[key]['2'].to_f)]]
      total_collection['cash'] += collection_hash[key]['1'] if collection_hash[key].keys.include?('1')
      total_collection['credit_card'] += collection_hash[key]['2'] if collection_hash[key].keys.include?('2')
    end
    result = result.sort_by { |x| [x[4].to_f, x[3].to_f] }.reverse
    result.unshift(['ID #', "Name", "Cash", "Credit Card", 'Total'])
    result += [['','','','','']]
    result += [['','Totals:', "%.2f"%total_collection['cash'], "%.2f"%total_collection['credit_card'], "%.2f"%(total_collection['cash']+total_collection['credit_card'])]]
  end
end
