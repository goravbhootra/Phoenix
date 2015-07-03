class CreateFirstMasterTables < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string     :name,             limit: 100, null: false
      t.string     :ancestry
      t.boolean    :active,           default: true, null: false
      t.integer    :position
      t.timestamps                    null: false
      t.index(:name, unique: true)
    end
    add_column :languages, :code, :string, limit: 3, null: false
    add_index :languages, :code, unique: true

    create_table :categories do |t|
      t.string     :name,             limit: 100, null: false
      t.string     :ancestry,         index: true
      t.boolean    :active,           default: true, null: false
      t.integer    :position
      t.timestamps                    null: false
      t.index(:name, unique: true)
    end
    add_column :categories, :code, :string, limit: 3, null: false
    add_index :categories, :code, unique: true

    create_table :focus_groups do |t|
      t.string     :name,             limit: 100, null: false
      t.boolean    :active,           default: true
      t.integer    :position
      t.timestamps                    null: false
      t.index(:name, unique: true)
    end

    create_table :distribution_types do |t|
      t.string     :name,             limit: 100, null: false
      t.boolean    :active,           default: true, null: false
      t.integer    :position
      t.timestamps                    null: false
      t.index(:name, unique: true)
    end

    create_table :authors do |t|
      t.string     :name,             limit: 100, null: false
      t.boolean    :active,           default: true, null: false
      t.integer    :position
      t.timestamps                    null: false
      t.index(:name, unique: true)
    end

    create_table :core_levels do |t|
      t.string     :name,             limit: 100, null: false
      t.boolean    :active,           default: true, null: false
      t.integer    :position
      t.timestamps                    null: false
      t.index(:name, unique: true)
    end
  end
end
