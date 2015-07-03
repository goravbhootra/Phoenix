class CreatePurInvoiceTables < ActiveRecord::Migration
  def change
    create_table :pur_invoices do |t|
      t.belongs_to :currency,             required: true, null: false
      t.belongs_to :created_by,           required: true, null: false
      t.text       :remarks
      t.float      :amount,               null: false, precision: 9, scale: 2
      t.string     :number,               null: false, limit: 10
      t.timestamps                        null: false
      t.float      :tax_amount,           null: false, precision: 9, scale: 2
      t.datetime   :issue_date,           null: false
      t.integer    :status,               null: false
      t.string     :ref_number,           limit: 10
      t.index(:currency_id)
      t.index(:created_by_id)
      t.index(:number, unique: true)
    end
    add_foreign_key :pur_invoices, :currencies, on_delete: :restrict
    add_foreign_key :pur_invoices, :business_entity_users, column: :created_by_id, primary_key: :id, on_delete: :restrict
    # execute "ALTER TABLE ONLY pur_invoices ADD CONSTRAINT positive_amount CHECK (amount >= 0);"
    # ALTER TABLE the_table ADD CONSTRAINT constraint_name UNIQUE (thecolumn);

    create_table :pur_invoice_line_items do |t|
      t.belongs_to :pur_invoice,          required: true, null: false
      t.belongs_to :product,              required: true, null: false
      t.integer    :quantity,             null: false
      t.float      :amount,               null: false, precision: 10, scale: 2
      t.float      :tax_amount,           null: false, precision: 10, scale: 2
      t.boolean    :received,             default: false
      t.timestamps                        null: false
      t.index([:pur_invoice_id, :product_id], unique: true)
    end
    add_foreign_key :pur_invoice_line_items, :pur_invoices, on_delete: :restrict
    add_foreign_key :pur_invoice_line_items, :products, on_delete: :restrict
    # execute "ALTER TABLE ONLY pur_invoice_line_items
    #     ADD CONSTRAINT positive_amount CHECK (amount >= 0),
    #     ADD CONSTRAINT positive_quantity CHECK (quantity >= 0);"

    create_table :pur_invoice_payments do |t|
      t.belongs_to :pur_invoice,          required: true, null: false
      t.belongs_to :payment_mode,         required: true, null: false
      t.belongs_to :issued_by,            required: true, null: false
      t.float      :amount,               null: false, precision: 9, scale: 2
      t.timestamps                        null: false
      t.index([:pur_invoice_id, :payment_mode_id], unique: true, name: 'idx_pur_inv_payments_on_pur_inv_id_and_payment_mode_id')
      t.index(:issued_by_id)
    end
    add_foreign_key :pur_invoice_payments, :pur_invoices, on_delete: :restrict
    add_foreign_key :pur_invoice_payments, :payment_modes, on_delete: :restrict
    add_foreign_key :pur_invoice_payments, :business_entity_users, column: :issued_by_id, primary_key: :id, on_delete: :restrict
    # execute "ALTER TABLE ONLY pur_invoice_payments ADD CONSTRAINT positive_amount CHECK (amount >= 0);"
  end
end
