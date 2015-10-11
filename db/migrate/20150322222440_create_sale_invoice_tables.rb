class CreateSaleInvoiceTables < ActiveRecord::Migration
  def change
    create_table :sale_invoices do |t|
      t.belongs_to :member,                     required: true, null: false
      t.belongs_to :currency,                   required: true, null: false
      t.belongs_to :created_by,                 required: true, null: false
      t.text       :remarks
      t.float      :total_amount,               null: false, precision: 9, scale: 2
      t.timestamps                              null: false
      t.float      :tax_amount,                 null: false, precision: 9, scale: 2
      t.datetime   :issue_date,                 null: false
      t.integer    :status,                     null: false, comment: 'Published: 1, Draft: 2, Deleted: 3, Waiting_Approval: 4'
      t.string     :ref_number,                 limit: 30
      t.belongs_to :voucher_sequence,           required: true, null: false
      t.integer    :number,                     null: false
      t.string     :number_prefix,              limit: 8
      t.float      :goods_value,                null: false, precision: 10, scale: 2
      t.hstore     :additional_charges_details
      t.float      :additional_charges,         precision: 8, scale: 2
      t.text       :address
      t.hstore     :tax_details
      t.belongs_to :business_entity_location,   null: false
      t.index(:member_id)
      t.index(:currency_id)
      t.index(:created_by_id)
      t.index([:number, :number_prefix, :voucher_sequence_id], unique: true, name: 'idx_sale_invoices_on_number_n_prefix_n_voucher_sequence')
      t.index(:business_entity_location_id)
    end
    add_foreign_key :sale_invoices, :currencies, on_delete: :restrict
    add_foreign_key :sale_invoices, :business_entity_users, column: :created_by_id, primary_key: :id, on_delete: :restrict
    add_foreign_key :sale_invoices, :voucher_sequences, on_delete: :restrict
    add_foreign_key :sale_invoices, :business_entity_locations, on_delete: :restrict
    remove_index :sale_invoices, :created_by_id
    remove_foreign_key :sale_invoices, :created_by
    rename_column :sale_invoices, :created_by_id, :business_entity_user_id
    add_column :sale_invoices, :created_by_id, :integer, null: false
    add_index :sale_invoices, :created_by_id
    add_foreign_key :sale_invoices, :users, column: :created_by_id, primary_key: :id, on_delete: :restrict
    change_column_null(:sale_invoices, :business_entity_user_id, true)
    remove_column :sale_invoices, :business_entity_user_id, :integer

    rename_column :sale_invoices, :issue_date, :voucher_date

    create_table :sale_invoice_line_items do |t|
      t.belongs_to :sale_invoice,                 required: true, null: false
      t.belongs_to :product,                      required: true, null: false
      t.integer    :quantity,                     null: false
      t.float      :amount,                       null: false, precision: 10, scale: 2
      t.float      :tax_amount,                   null: false, precision: 10, scale: 2
      t.boolean    :delivered,                    null: false, default: false
      t.timestamps                                null: false
      t.belongs_to :state_category_tax_rate,      required: true, null: false
      t.string     :tax_rate,                     limit: 12
      t.float      :rate,                         null: false, precision: 10, scale: 2
      t.index([:sale_invoice_id, :product_id], unique: true)
      t.index(:state_category_tax_rate_id)
    end
    add_foreign_key :sale_invoice_line_items, :sale_invoices, on_delete: :restrict
    add_foreign_key :sale_invoice_line_items, :products, on_delete: :restrict
    add_foreign_key :sale_invoice_line_items, :state_category_tax_rates, on_delete: :restrict
    # add_foreign_key :sale_invoice_line_items, :business_entity_locations, on_delete: :restrict
    # execute "ALTER TABLE ONLY sale_invoice_line_items
    #     ADD CONSTRAINT positive_amount CHECK (amount >= 0),
    #     ADD CONSTRAINT positive_quantity CHECK (quantity >= 0);"

    create_table :sale_invoice_payments do |t|
      t.belongs_to :sale_invoice,         required: true, null: false
      t.belongs_to :payment_mode,         required: true, null: false
      t.belongs_to :received_by,          required: true, null: false
      t.float      :amount,               null: false, precision: 9, scale: 2
      t.timestamps                        null: false
      t.hstore     :payment_remarks
      t.index([:sale_invoice_id, :payment_mode_id], unique: true, name: 'idx_sale_inv_payments_on_sale_inv_id_and_payment_mode_id')
      t.index(:received_by_id)
    end
    add_foreign_key :sale_invoice_payments, :sale_invoices, on_delete: :restrict
    add_foreign_key :sale_invoice_payments, :payment_modes, on_delete: :restrict
    add_foreign_key :sale_invoice_payments, :business_entity_users, column: :received_by_id, primary_key: :id, on_delete: :restrict
    # execute "ALTER TABLE ONLY sale_invoice_payments ADD CONSTRAINT positive_amount CHECK (amount >= 0);"
    remove_index :sale_invoice_payments, :received_by_id
    remove_foreign_key :sale_invoice_payments, :received_by
    rename_column :sale_invoice_payments, :received_by_id, :business_entity_user_id
    add_column :sale_invoice_payments, :received_by_id, :integer
    add_index :sale_invoice_payments, :received_by_id
    add_foreign_key :sale_invoice_payments, :users, column: :received_by_id, primary_key: :id, on_delete: :restrict
    change_column_null(:sale_invoice_payments, :business_entity_user_id, true)
    remove_column :sale_invoice_payments, :business_entity_user_id, :integer
  end
end
