class PaymentMode < MyActiveRecord
  has_many :invoice_payments, class_name: 'InvoicePayment', foreign_key: 'mode_id', inverse_of: :mode, dependent: :restrict_with_exception

  validates :name, presence: true, length: { in: 3..100 }, uniqueness: { case_sensitive: false }
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where active: true }
  scope :available_for_invoices, -> { active.where("show_on_invoice = true OR id = 5") } # 5: Change tendered
end
