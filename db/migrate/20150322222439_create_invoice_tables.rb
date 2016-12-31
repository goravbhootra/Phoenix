class CreateInvoiceTables < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.belongs_to :currency,                     null: false
      t.belongs_to :voucher_sequence,             null: false
      t.belongs_to :primary_location,             null: false
      t.belongs_to :secondary_entity,             null: false
      t.belongs_to :created_by,                   null: false
      t.integer    :number,                       null: false
      t.string     :number_prefix,                limit: 8
      t.text       :remarks
      t.datetime   :invoice_date,                 null: false
      t.integer    :status,                       null: false
      t.string     :ref_number,                   limit: 30
      t.decimal    :goods_value,                  precision: 10, scale: 2, null: false
      t.decimal    :tax_amount,                   precision: 10, scale: 2, null: false
      t.decimal    :total_amount,                 precision: 10, scale: 2, null: false
      t.text       :address
      t.hstore     :tax_details
      t.string     :customer_membership_number,   limit: 9
      t.string     :type,                         null: false
      t.timestamps                                null: false
      t.index(:currency_id)
      t.index([:number_prefix, :number], unique: true)
      t.index([:voucher_sequence_id, :number], unique: true)
      t.index(:created_by_id)
      t.index(:invoice_date)
      t.index(:type)
    end
    add_foreign_key :invoices, :currencies, on_delete: :restrict
    add_foreign_key :invoices, :voucher_sequences, on_delete: :restrict
    add_foreign_key :invoices, :business_entity_locations, column: :primary_location_id, on_delete: :restrict
    add_foreign_key :invoices, :business_entities, column: :secondary_entity_id, on_delete: :restrict
    add_foreign_key :invoices, :users, column: :created_by_id, on_delete: :restrict

    create_table :invoice_payments do |t|
      t.belongs_to  :invoice,           null: false
      t.belongs_to  :mode,              null: false
      t.belongs_to  :received_by,       null: false
      t.decimal     :amount,            precision: 10, scale: 2, null: false
      t.hstore      :additional_details
      t.timestamps                      null: false
      t.index [:invoice_id, :mode_id], unique: true
      t.index [:received_by_id]
    end
  end
end
