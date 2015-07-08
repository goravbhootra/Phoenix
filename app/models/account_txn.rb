class AccountTxn < MyActiveRecord
  belongs_to :business_entity, inverse_of: :account_txns
  belongs_to :currency, inverse_of: :account_txns
  belongs_to :voucher_sequence, inverse_of: :account_txns
  belongs_to :created_by, class_name: 'User', inverse_of: :created_account_txns

  validates :business_entity, presence: true
  validates :currency, :voucher_sequence_id, :created_by, presence: true
  validates :type, presence: true
  validates :number_prefix, length: { maximum: 8 }
  validates :number, presence: true, numericality: true, uniqueness: { scope: [:business_entity_id, :number_prefix], case_sensitive: false }
  validates :txn_date, presence: true
  validates :status, presence: true
  validates :ref_number, length: { maximum: 30 }

  attr_accessor :current_user_id
end
