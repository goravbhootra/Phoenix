module AccountEntriesExtension
  def balance
    reject(&:marked_for_destruction?).sum(&:amount)
  end
end
