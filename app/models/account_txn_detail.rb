class AccountTxnDetail < ActiveRecord::Base
  belongs_to :account_txn, inverse_of: :detail, touch: true

  validates :account_txn, presence: true, uniqueness: true
  validates :customer_membership_number, length: { is: 9 }, allow_nil: true, allow_blank: true
end
