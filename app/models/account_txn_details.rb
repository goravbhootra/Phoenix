class AccountTxnDetails < ActiveRecord::Base
  validates :customer_membership_number, length: { is: 9 }, allow_nil: true, allow_blank: true
end
