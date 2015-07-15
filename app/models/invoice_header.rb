class InvoiceHeader < ActiveRecord::Base
  belongs_to :account_txn, inverse_of: :header, touch: true
  belongs_to :business_entity_location, inverse_of: :invoice_headers

  validates :account_txn, presence: true, uniqueness: true
  validates :business_entity_location, presence: true
  validates :customer_membership_number, length: { is: 9 }, allow_nil: true, allow_blank: true

  def location
    business_entity_location
  end
end
