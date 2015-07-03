module VoucherSequenceable
  extend ActiveSupport::Concern

  def get_voucher_sequences
    if params[:business_entity_location_id].present?
      render json: VoucherSequence.send("anc_#{controller_name.underscore.pluralize}", params[:voucher_sequence_id].to_i).
        where(business_entity_id:
              BusinessEntityLocation.find(params[:business_entity_location_id].to_i).
              business_entity_id).pluck(:id)
    else
      render json: {}
    end
    # render text: @voucher_sequences.map { |vs| { id: vs.id, text: vs.number_prefix } }
    # render html: @voucher_sequences.map { |vs| "<option value=#{vs.id}>#{vs.number_prefix}</option>" }
  end
end