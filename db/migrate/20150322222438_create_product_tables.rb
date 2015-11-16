class CreateProductTables < ActiveRecord::Migration
  def change
    create_table :product_groups do |t|
      t.string     :name,                 null: false, limit: 100
      t.boolean    :active,               null: false, default: true
      t.integer    :position
      t.timestamps                        null: false
      t.index(:name, unique: true)
    end

    create_table :uoms do |t|
      t.string     :name,                 null: false, limit: 50
      t.string     :print_name,           null: false, limit: 5
      t.boolean    :active,               null: false, default: true
      t.integer    :position
      t.timestamps                        null: false
      t.index(:name, unique: true)
      t.index(:print_name, unique: true)
    end

    create_table :products do |t|
      t.belongs_to :product_group
      t.belongs_to :category,             required: true, null: false
      t.belongs_to :core_level
      t.belongs_to :author
      t.belongs_to :distribution_type,    null: false, default: 1
      t.belongs_to :language
      t.belongs_to :publisher,            null: false, required: true, default: 1
      t.belongs_to :uom,                  required: true, null: false, default: 1
      t.belongs_to :focus_group,          default: 1
      t.integer    :sku,                  null: false
      t.string     :name,                 null: false
      t.string     :alias_name,           limit: 40
      t.text       :summary
      t.text       :synopsis
      t.date       :publication_date
      t.decimal    :mrp,                  null: false, precision: 8, scale: 2
      t.decimal    :selling_price,        null: false, precision: 8, scale: 2
      t.string     :isbn
      t.text       :notes
      t.hstore     :details
      t.boolean    :active,               null: false, default: true
      t.integer    :position
      t.timestamps                        null: false
      t.index([:name, :category_id, :language_id, :selling_price], unique: true, name: 'idx_product_category_language_selling_price_unique')
      t.index(:product_group_id)
      t.index(:category_id)
      t.index(:core_level_id)
      t.index(:author_id)
      t.index(:distribution_type_id)
      t.index(:language_id)
      t.index(:publisher_id)
      t.index(:focus_group_id)
      t.index(:sku, unique: true)
      t.index(:alias_name)
    end
    add_foreign_key :products, :product_groups, on_delete: :restrict
    add_foreign_key :products, :categories, on_delete: :restrict
    add_foreign_key :products, :authors, on_delete: :restrict
    add_foreign_key :products, :core_levels, on_delete: :restrict
    add_foreign_key :products, :distribution_types, on_delete: :restrict
    add_foreign_key :products, :languages, on_delete: :restrict
    add_foreign_key :products, :uoms, on_delete: :restrict
    add_foreign_key :products, :publishers, on_delete: :restrict
    # execute "ALTER TABLE ONLY products ADD CONSTRAINT positive_ecom_quantity
        # CHECK (ecom_quantity >= 0 and ecom_quantity <= 100);"

    remove_index :products, column: :alias_name
    remove_index :products, column: :language_id
    remove_index :products, column: :category_id
    add_index :products, [:alias_name, :language_id, :category_id, :selling_price], unique: true, name: 'idx_prodcts_on_alias_name_n_language_n_category_n_selling_price'
    change_column_null(:products, :alias_name, false)
  end
end
