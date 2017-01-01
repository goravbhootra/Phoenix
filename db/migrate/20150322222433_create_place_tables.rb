class CreatePlaceTables < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string     :name,                 limit: 100, null: false
      t.string     :code,                 null: false, limit: 3
      t.boolean    :active,               default: true, null: false
      t.boolean    :reserved,             null: false, default: false
      t.integer    :position
      t.timestamps                        null: false
    end
    execute 'CREATE UNIQUE INDEX name_unique_idx on currencies (LOWER(name));'
    execute 'CREATE UNIQUE INDEX code_unique_idx on currencies (UPPER(code));'

    create_table :regions do |t|
      t.string     :name,                 limit: 50, null: false
      t.string     :code,                 null: false, limit: 3
      t.belongs_to :currency,             required: true, null: false
      t.boolean    :active,               default: true, null: false
      t.boolean    :reserved,             null: false, default: false
      t.integer    :position
      t.timestamps                        null: false
      t.index(:currency_id)
    end
    execute 'CREATE UNIQUE INDEX name_unique_idx_on_regions on regions (LOWER(name));'
    execute 'CREATE UNIQUE INDEX code_unique_idx_on_regions on regions (UPPER(code));'
    add_foreign_key :regions, :currencies, on_delete: :restrict

    create_table :states do |t|
      t.string     :name,                 limit: 50, null: false
      t.belongs_to :region,               required: true, null: false
      t.string     :code,                 null: false, limit: 3
      t.boolean    :active,               default: true, null: false
      t.boolean    :reserved,             null: false, default: false
      t.integer    :position
      t.timestamps                        null: false
    end
    execute 'CREATE UNIQUE INDEX name_n_region_unique_idx_on_states on states (LOWER(name), region_id);'
    execute 'CREATE UNIQUE INDEX code_unique_idx_on_states on states (UPPER(code));'
    add_foreign_key :states, :regions, on_delete: :restrict

    create_table :zones do |t|
      t.string     :name,                 null: false, limit: 50
      t.belongs_to :region,               required: true, null: false
      t.string     :code,                 null: false, limit: 3
      t.boolean    :active,               default: true, null: false
      t.boolean    :reserved,             null: false, default: false
      t.integer    :position
      t.timestamps                        null: false
    end
    execute 'CREATE UNIQUE INDEX name_n_region_unique_idx_on_zones on zones (LOWER(name), region_id);'
    execute 'CREATE UNIQUE INDEX code_unique_idx_on_zones on zones (UPPER(code));'
    add_foreign_key :zones, :regions, on_delete: :restrict

    create_table :cities do |t|
      t.string     :name,                 null: false, limit: 50
      t.belongs_to :state,                null: false, required: true
      t.belongs_to :zone,                 null: false, required: true
      t.boolean    :active,               default: true, null: false
      t.boolean    :reserved,             null: false, default: false
      t.integer    :position
      t.timestamps                        null: false
    end
    execute 'CREATE UNIQUE INDEX name_n_zone_unique_idx_on_cities on cities (LOWER(name), zone_id);'
    execute 'CREATE UNIQUE INDEX name_n_state_unique_idx_on_cities on cities (LOWER(name), state_id);'
    add_foreign_key :cities, :states, on_delete: :restrict
    add_foreign_key :cities, :zones, on_delete: :restrict
  end
end
