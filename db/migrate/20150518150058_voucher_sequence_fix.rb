class VoucherSequenceFix < ActiveRecord::Migration
  def change
    remove_index :voucher_sequences, name: 'idx_voucher_seq_on_name_n_bus_entity_n_clasfction_n_valid_from'
    remove_column :voucher_sequences, :name, :string
    execute "CREATE UNIQUE INDEX idx_voucher_seq_on_business_entity_n_classification_n_valid_from ON voucher_sequences (classification, business_entity_id, valid_from) WHERE number_prefix IS NULL"
    execute "CREATE UNIQUE INDEX idx_voucher_seq_on_num_prfx_bus_entity_n_clasfctn_n_valid_from ON voucher_sequences (classification, business_entity_id, valid_from, number_prefix) WHERE number_prefix IS NOT NULL"
    BusinessEntity.all.each { |be| VoucherSequence.create!(business_entity_id: be.id, classification: 4, valid_from: "1/4/2015", active: true) }
  end
end
