class InventoryTxnFilter < ActiveType::Object

  attribute :from_date, :datetime, default: proc { Date.parse('01/04/2015') }
  attribute :to_date, :datetime, default: proc { Time.zone.now }
  attribute :location_id

  validates :location_id, inclusion: { in: BusinessEntityLocation.pluck(:id) }
end
