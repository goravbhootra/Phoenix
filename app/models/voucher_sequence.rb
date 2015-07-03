class VoucherSequence < MyActiveRecord
  belongs_to :business_entity, inverse_of: :voucher_sequences
  has_many :inventory_txns, inverse_of: :voucher_sequence, dependent: :restrict_with_exception
  has_many :invoices, inverse_of: :voucher_sequence, dependent: :restrict_with_exception
  has_many :inventory_vouchers, inverse_of: :voucher_sequence, dependent: :restrict_with_exception

  validates :business_entity_id, presence: true
  validates :classification, presence: true
  validates :starting_number, presence: true, numericality: true
  validates :number_prefix, length: { maximum: 8 }
  validates :valid_from, presence: true
  validate :combination_check
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where active: true }
  scope :anc_pos_invoices, -> (voucher_sequence_id=nil) { active_n_current(voucher_sequence_id).where classification: 1 }
  scope :anc_inventory_out_vouchers, -> (voucher_sequence_id=nil) { active_n_current(voucher_sequence_id).where classification: 2 }
  scope :anc_inventory_in_vouchers, -> (voucher_sequence_id=nil) { active_n_current(voucher_sequence_id).where classification: 3 }
  scope :anc_inventory_internal_transfer_vouchers, -> (voucher_sequence_id=nil) { active_n_current(voucher_sequence_id).where classification: 4 }

  def self.active_n_current(current_record_id=nil)
    where("id IN (?)", (active.pluck(:id)+[current_record_id.to_i]-[0]).uniq)
  end

  delegate :alias_name, to: :business_entity, prefix: true, allow_nil: true

  enum classification: {
                          'PosInvoice': 1,
                          'InventoryOutVoucher': 2,
                          'InventoryInVoucher': 3,
                          'Int. Tnsfr Voucher': 4
                        }

  # def classification_enum
  #   { 'PosInvoice': 1, 'InventoryOutVoucher': 2, 'InventoryInVoucher': 3, 'Int. Tnsfr Voucher': 4 }
  # end

  def combination_check
    errors.add(:base, 'valid_from, business_entity, classification and number prefix combination should be unique') if VoucherSequence.where(business_entity_id: self.business_entity_id, classification: self.classification, valid_from: self.valid_from).where(number_prefix: nil).exists?
    errors.add(:base, 'valid_from, business_entity, classification and number prefix combination should be unique') if VoucherSequence.where(business_entity_id: self.business_entity_id, classification: self.classification, valid_from: self.valid_from, number_prefix: number_prefix).where.not(number_prefix: nil).exists?
    # :valid_from, uniqueness: {scope: [:business_entity_id, :classification], message: }, unless: :
  end
end
