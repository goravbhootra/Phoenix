class CreateSecondMasterTables < ActiveRecord::Migration
  def change
    create_table :payment_modes do |t|
      t.string     :name,                 limit: 100, null: false
      t.boolean    :active,               default: true, null: false
      t.integer    :position
      t.timestamps                        null: false
      t.boolean    :show_on_invoice,      null: false, default: true
      t.index(:name, unique: true)
    end

    create_table :state_category_tax_rates do |t|
      t.belongs_to :state,                null: false, required: true
      t.belongs_to :category,             null: false, required: true
      t.integer    :classification,       null: false, default: 1, comment: "sales: 1, purchase: 2"
      t.string     :interstate_label,     null: false, limit: 10
      t.decimal    :interstate_rate,      null: false, precision: 5, scale: 2
      t.string     :intrastate_label,     null: false, limit: 10
      t.decimal    :intrastate_rate,      null: false, precision: 5, scale: 2
      t.datetime   :valid_from,           null: false
      t.datetime   :valid_till
      t.boolean    :active,               default: true, null: true
      t.integer    :position
      t.timestamps                        null: false
      t.index([:state_id, :category_id, :valid_from], unique: true,
              name: 'idx_state_cat_tax_rates_on_state_n_cat_n_valid_from')
    end
    add_foreign_key :state_category_tax_rates, :states, on_delete: :restrict
    add_foreign_key :state_category_tax_rates, :categories, on_delete: :restrict
  end
end
