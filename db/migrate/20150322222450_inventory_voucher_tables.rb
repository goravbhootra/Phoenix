class InventoryVoucherTables < ActiveRecord::Migration
  def change
    create_table :inventory_vouchers do |t|
      t.belongs_to :business_entity,                required: true, null: false
      t.belongs_to :sale_invoice
      t.belongs_to :pur_invoice
      t.belongs_to :voucher_sequence,               required: true, null: false
      t.belongs_to :created_by,                     required: true, null: false
      t.belongs_to :currency,                       required: true, null: false
      t.integer    :classification,                 null: false, comment: 'opening_stock: 1, surplus_stock: 2, stock_shortfall: 3, sale_reversal: 4, purchase_reversal: 5, adjustment_with_reason: 6'
      t.float      :total_amount,                   null: false, precision: 10, scale: 2
      t.datetime   :voucher_date,                   null: false
      t.integer    :number,                         null: false
      t.string     :number_prefix,                  limit: 8
      t.string     :ref_number,                     limit: 30
      t.text       :remarks
      t.integer    :status,                         null: false, comment: 'Active: 1, Draft: 2, Deleted: 3, Waiting_Approval: 4'
      t.timestamps                                  null: false
      t.belongs_to :business_entity_location,       null: false
      t.belongs_to :receiving_business_entity_location
      t.index(:business_entity_id)
      t.index([:classification, :sale_invoice_id, :pur_invoice_id], name: 'idx_stock_adj_on_classification_n_sale_inv_id_n_pur_inv_id')
      t.index([:number, :voucher_sequence_id], unique: true)
      t.index(:created_by_id)
    end
    add_foreign_key :inventory_vouchers, :business_entities, on_delete: :restrict
    add_foreign_key :inventory_vouchers, :sale_invoices, on_delete: :restrict
    add_foreign_key :inventory_vouchers, :pur_invoices, on_delete: :restrict
    add_foreign_key :inventory_vouchers, :voucher_sequences, on_delete: :restrict
    add_foreign_key :inventory_vouchers, :business_entity_users, column: :created_by_id, primary_key: :id, on_delete: :restrict
    add_foreign_key :inventory_vouchers, :currencies, on_delete: :restrict
    add_foreign_key :inventory_vouchers, :business_entity_locations, column: :business_entity_location_id, primary_key: :id, on_delete: :restrict
    add_foreign_key :inventory_vouchers, :business_entity_locations, column: :receiving_business_entity_location_id, primary_key: :id, on_delete: :restrict

    remove_index :inventory_vouchers, :created_by_id
    remove_foreign_key :inventory_vouchers, :created_by
    rename_column :inventory_vouchers, :created_by_id, :business_entity_user_id
    add_column :inventory_vouchers, :created_by_id, :integer, null: false
    add_index :inventory_vouchers, :created_by_id
    add_foreign_key :inventory_vouchers, :users, column: :created_by_id, primary_key: :id, on_delete: :restrict
    change_column_null(:inventory_vouchers, :business_entity_user_id, true)

    remove_column :inventory_vouchers, :business_entity_user_id, :integer
    add_column :inventory_vouchers, :receiving_business_entity_id, :integer
    add_index :inventory_vouchers, :receiving_business_entity_id
    add_foreign_key :inventory_vouchers, :business_entities, column: :receiving_business_entity_id, on_delete: :restrict
    remove_index :inventory_vouchers,
                name: 'idx_stock_adj_on_classification_n_sale_inv_id_n_pur_inv_id'
    add_index :inventory_vouchers, :classification
    remove_foreign_key :inventory_vouchers, :sale_invoices
    remove_foreign_key :inventory_vouchers, :pur_invoices
    remove_column :inventory_vouchers, :sale_invoice_id, :integer
    remove_column :inventory_vouchers, :pur_invoice_id, :integer

    add_index :inventory_vouchers, :business_entity_location_id
    add_index :inventory_vouchers, :receiving_business_entity_location_id, name: 'idx_inventory_vouchers_on_rec_business_entity_location_id'

    create_table :inventory_voucher_line_items do |t|
      t.belongs_to :inventory_voucher,        required: true, null: false
      t.belongs_to :product,                  required: true, null: false
      t.integer    :quantity,                 null: false
      t.float      :amount,                   null: false, precision: 10, scale: 2
      t.timestamps                            null: false
      t.integer    :received_quantity
      t.float      :rate,                     null: false, precision: 10, scale: 2
      t.index([:inventory_voucher_id, :product_id], unique: true,
              name: 'idx_stock_adj_items_on_stock_adj_id_n_product_id')
      # t.index([:inventory_voucher_line_items, :business_entity_location_id],
              # name: 'idx_stock_adjustment_line_items_on_business_entity_location_id')
      # t.index([:inventory_voucher_line_items, :receiving_business_entity_location_id],
              # name: 'idx_inv_voucher_line_items_on_receiving_bus_entity_location')
    end
    add_foreign_key :inventory_voucher_line_items, :inventory_vouchers, on_delete: :restrict
    add_foreign_key :inventory_voucher_line_items, :products, on_delete: :restrict

    create_table :location_inventory_levels do |t|
      t.belongs_to :business_entity_location, required: true, null: false
      t.belongs_to :product,                  required: true, null: false
      t.integer    :classification,           null: false
      t.integer    :quantity,                 null: false
      t.boolean    :active,                   null: false, default: true
      t.timestamps                            null: false
      t.index([:business_entity_location_id, :product_id, :classification], unique: true,
               name: 'idx_location_product_classification_uniq')
    end
    add_foreign_key :location_inventory_levels, :business_entity_locations, on_delete: :restrict
    add_foreign_key :location_inventory_levels, :products, on_delete: :restrict
  end
end
