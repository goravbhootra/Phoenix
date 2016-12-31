class CreateInventoryTxnsTables < ActiveRecord::Migration
  def change
    create_table :inventory_txns do |t|
      t.belongs_to :created_by,                 required: true, null: false
      t.belongs_to :primary_entity,             null: false
      t.belongs_to :primary_location,           null: false
      t.belongs_to :secondary_entity,           null: false
      t.belongs_to :secondary_location,         null: false
      t.belongs_to :invoice
      t.text       :remarks
      t.decimal    :total_amount,               null: false, precision: 10, scale: 2
      t.datetime   :voucher_date,               null: false
      t.integer    :status,                     null: false, comment: 'Published: 1, Draft: 2, Deleted: 3, Waiting_Approval: 4'
      t.string     :ref_number,                 limit: 30
      t.belongs_to :voucher_sequence,           required: true, null: false
      t.integer    :number,                     null: false
      t.string     :number_prefix,              limit: 8
      t.decimal    :additional_charges,         null: false, precision: 10, scale: 2
      t.text       :address
      t.string     :type,                       null: false
      t.timestamps                              null: false
      t.index([:number, :number_prefix, :voucher_sequence_id], unique: true, name: 'idx_inventory_txns_on_number_n_prefix_n_voucher_sequence')
      t.index(:primary_entity_id)
      t.index(:primary_location_id)
      t.index(:secondary_entity_id)
      t.index(:secondary_location_id)
      t.index(:created_by_id)
      t.index(:invoice_id, order: { invoice_id: "DESC NULLS LAST" })
    end
    add_foreign_key :inventory_txns, :voucher_sequences, on_delete: :restrict
    add_foreign_key :inventory_txns, :users, column: :created_by_id, primary_key: :id,
                    on_delete: :restrict
    add_foreign_key :inventory_txns, :business_entities, column: :primary_entity_id,
                    on_delete: :restrict
    add_foreign_key :inventory_txns, :business_entity_locations, column: :primary_location_id,
                    on_delete: :restrict
    add_foreign_key :inventory_txns, :business_entities, column: :secondary_entity_id,
                    on_delete: :restrict
    add_foreign_key :inventory_txns, :business_entity_locations, column: :secondary_location_id,
                    on_delete: :restrict
    add_foreign_key :inventory_txns, :invoices, on_delete: :restrict
    execute "alter table inventory_txns ADD CONSTRAINT secondary_account_xor_location check(
      (secondary_entity_id IS NOT null)::integer +
      (secondary_location_id  IS NOT null)::integer = 1
    );"

    create_table :inventory_txn_line_items do |t|
      t.belongs_to :inventory_txn,                required: true, null: false
      t.belongs_to :product,                      required: true, null: false
      t.integer    :quantity_in
      t.integer    :quantity_out
      t.decimal    :amount,                       null: false, precision: 10, scale: 2
      t.decimal    :tax_amount,                   null: false, precision: 10, scale: 2
      t.decimal    :tax_rate,                     null: false, precision: 5, scale: 2
      t.decimal    :price,                        null: false, precision: 8, scale: 2
      t.timestamps                                null: false
      t.index([:inventory_txn_id, :product_id], unique: true,
              name: 'idx_inventory_txn_line_items_on_sale_invoice_id_and_product_id'
            )
    end
    add_foreign_key :inventory_txn_line_items, :inventory_txns, on_delete: :restrict
    add_foreign_key :inventory_txn_line_items, :products, on_delete: :restrict
    # execute "alter table inventory_txn_line_items ADD CONSTRAINT quantity_in_xor_quantity_out check(
    #   (quantity_in  IS NOT null)::integer +
    #   (quantity_out IS NOT null)::integer = 1
    # );"
  end
end
