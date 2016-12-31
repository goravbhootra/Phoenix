class CreateFirstMasterTables < ActiveRecord::Migration
  def change
    create_table :languages do |t|
      t.string     :name,             limit: 100, null: false
      t.string     :ancestry
      t.string     :code,             limit: 3, null: false
      t.boolean    :active,           default: true, null: false
      t.integer    :position
      t.timestamps                    null: false
      t.index(:name, unique: true)
      t.index(:code, unique: true)
    end

    create_table :categories do |t|
      t.string     :name,             limit: 100, null: false
      t.string     :ancestry,         index: true
      t.string     :code,             limit: 3, null: false
      t.boolean    :active,           default: true, null: false
      t.integer    :position
      t.timestamps                    null: false
      t.index(:name, unique: true)
      t.index(:code, unique: true)
    end

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
