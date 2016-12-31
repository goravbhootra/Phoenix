class CreateUserTables < ActiveRecord::Migration
	def change
    create_table :users do |t|
      t.string     :name,                      limit: 100, null: false
      t.string     :membership_number,         limit: 9, null: false
      t.belongs_to :city,                    required: true, null: false
      t.string     :email,                     limit: 100, null: false
      t.string     :password_digest,           null: false
      t.string     :contact_number_primary,    limit: 15
      t.string     :contact_number_secondary,  limit: 15
      t.boolean    :reserved,                  null: false, default: false
      t.text       :address
      t.boolean    :active,                    default: false, null: true
      t.inet       :current_sign_in_ip
      t.inet       :last_sign_in_ip
      t.integer    :sign_in_count
      t.string     :auth_token,                null: false
      t.string     :password_reset_token
      t.datetime   :password_reset_sent_at
      t.string     :email_confirmation_token
      t.datetime   :email_confirmation_sent_at
      t.datetime   :confirmed_at
      t.datetime   :current_sign_in_at
      t.datetime   :last_sign_in_at
      t.integer    :position
      t.timestamps                             null: false
      t.index(:city_id)
      t.index(:email, unique: true)
      t.index(:auth_token, unique: true)
      t.index(:membership_number, unique: true)
    end
    add_foreign_key :users, :cities, on_delete: :restrict
    # execute "ALTER TABLE ONLY users ADD CONSTRAINT email_unique UNIQUE (email);"
	end
end
