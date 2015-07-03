module VoucherExtensible
  def get_business_entities
    render json: BusinessEntity.send("anc_with_reserved_#{controller_name.underscore.pluralize}", params[:business_entity_id].to_i).pluck(:id)-[BusinessEntityLocation.find(params[:business_entity_location_id].to_i).business_entity_id] if params[:business_entity_location_id].present?
  end

  def get_entity_locations
    render json: BusinessEntityLocation.joins(:business_entity).find(params[:primary_location_id].to_i).business_entity.locations.active_n_current(params[:secondary_location_id].to_i).pluck(:id)-[params[:primary_location_id].to_i] if params[:primary_location_id].present?
  end
end
