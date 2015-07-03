class CreateOrderTables < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :member,               required: true, null: false
      t.belongs_to :currency,             required: true, null: false
      t.belongs_to :booked_by,            required: true, null: false
      t.text :remarks
      t.float :amount,                    null: false, precision: 9, scale: 2
      t.string :number,                   null: false, limit: 10
      t.boolean :active,                  null: false, default: true
      t.timestamps                        null: false
      t.index(:member_id)
      t.index(:currency_id)
      t.index(:booked_by_id)
      t.index(:number, unique: true)
    end
    add_foreign_key :orders, :members, on_delete: :restrict
    add_foreign_key :orders, :currencies, on_delete: :restrict
    add_foreign_key :orders, :business_entity_users, column: :booked_by_id, primary_key: :id, on_delete: :restrict
    # execute "ALTER TABLE ONLY orders ADD CONSTRAINT positive_amount CHECK (amount >= 0);"

    remove_foreign_key :orders, :booked_by
    add_foreign_key :orders, :users, column: :booked_by_id, primary_key: :id, on_delete: :restrict

    create_table :order_line_items do |t|
      t.belongs_to :order,                required: true, null: false
      t.belongs_to :product,              required: true, null: false
      t.integer    :quantity,             null: false
      t.float      :amount,               null: false, precision: 8, scale: 2
      t.timestamps                        null: false
      t.index([:order_id, :product_id], unique: true)
    end
    add_foreign_key :order_line_items, :orders, on_delete: :restrict
    add_foreign_key :order_line_items, :products, on_delete: :restrict
    # execute "ALTER TABLE ONLY order_line_items
        # ADD CONSTRAINT positive_amount CHECK (amount >= 0),
        # ADD CONSTRAINT positive_quantity CHECK (quantity >= 0);"
  end
end
