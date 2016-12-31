class CreatePlaceTables < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string     :name,                 limit: 100, null: false
      t.string     :code,                 null: false, limit: 3
      t.boolean    :active,               default: true, null: false
      t.boolean    :reserved,             null: false, default: false
      t.integer    :position
      t.timestamps                        null: false
      t.index(:name, unique: true)
      t.index(:code, unique: true)
    end

    create_table :regions do |t|
      t.string     :name,                 limit: 50, null: false
      t.string     :code,                 null: false, limit: 3
      t.belongs_to :currency,             required: true, null: false
      t.boolean    :active,               default: true, null: false
      t.boolean    :reserved,             null: false, default: false
      t.integer    :position
      t.timestamps                        null: false
      t.index(:name, unique: true)
      t.index(:code, unique: true)
      t.index(:currency_id)
    end
    add_foreign_key :regions, :currencies, on_delete: :restrict

    create_table :states do |t|
      t.string     :name,                 limit: 50, null: false
      t.belongs_to :region,               required: true, null: false
      t.string     :code,                 null: false, limit: 3
      t.boolean    :active,               default: true, null: false
      t.boolean    :reserved,             null: false, default: false
      t.integer    :position
      t.timestamps                        null: false
      t.index([:name, :region_id], unique: true)
      t.index(:code, unique: true)
    end
    add_foreign_key :states, :regions, on_delete: :restrict

    create_table :zones do |t|
      t.string     :name,                 null: false, limit: 50
      t.belongs_to :region,               required: true, null: false
      t.string     :code,                 null: false, limit: 3
      t.boolean    :active,               default: true, null: false
      t.boolean    :reserved,             null: false, default: false
      t.integer    :position
      t.timestamps                        null: false
      t.index([:name, :region_id], unique: true)
      t.index(:code, unique: true)
    end
    add_foreign_key :zones, :regions, on_delete: :restrict

    create_table :cities do |t|
      t.string     :name,                 null: false, limit: 50
      t.belongs_to :state,                null: false, required: true
      t.belongs_to :zone,                 null: false, required: true
      t.boolean    :active,               default: true, null: false
      t.boolean    :reserved,             null: false, default: false
      t.integer    :position
      t.timestamps                        null: false
      t.index([:name, :state_id], unique: true)
      t.index([:name, :zone_id], unique: true)
    end
    add_foreign_key :cities, :states, on_delete: :restrict
    add_foreign_key :cities, :zones, on_delete: :restrict
  end
end
