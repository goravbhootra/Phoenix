class Power
  include Consul::Power

  def initialize(user)
    @user = user
    @roles = user.roles.pluck(:name, :id).to_h if user
    # @user_roles = user.user_roles.pluck(:role_id, )
  end

  def role?(roles=@roles)
    (@roles.keys & Array(roles)).present?
  end

  def global_role?
    role?(['admin', 'power_user'])
  end

  def get_my_locations
    return BusinessEntityLocation.where(active: true) if global_role?
    entities_and_locs = @user.user_roles.where("business_entity_id IS NOT NULL OR business_entity_location_id IS NOT NULL").pluck(:business_entity_id, :business_entity_location_id)
    BusinessEntityLocation.where('business_entity_id in (?) OR business_entity_locations.id in (?)', BusinessEntity.where(id: entities_and_locs.transpose[0].compact).pluck(:id).uniq, entities_and_locs.transpose[1].compact.uniq) if entities_and_locs.present?
  end

  def get_my_business_entities
    return BusinessEntity.where(active: true) if global_role?
    entities_and_locs = @user.user_roles.where("business_entity_id IS NOT NULL OR business_entity_location_id IS NOT NULL").pluck(:business_entity_id, :business_entity_location_id)
    BusinessEntity.where('id in (?) OR id in (?)', entities_and_locs.transpose[0].compact.uniq, BusinessEntityLocation.where(id: entities_and_locs.transpose[1].compact.uniq).pluck(:business_entity_id).uniq) if entities_and_locs.present?
  end

  # power :documents do
  #   owned_site_ids = Site.where(:owner_id => @user.id).collect_ids
  #   document_ids_as_site_owner = Document.where(:site => owned_site_ids).collect_ids
  #   document_ids_as_author = Document.where(:author_id => @user.id).collect_ids
  #   Document.where(:id => document_ids_as_site_owner + document_ids_as_author)
  # end

  # def power_user?(roles=@roles)
  #   roles.keys.include?('power_user')
  # end

  # power :users do
  #   User if admin?
  # end

  # power :notes do
  #   Note.by_author(@user)
  # end

  # power :dashboard do
  #   true # not a scope, but a boolean power. This is useful to control access to stuff that doesn't live in the database.
  # end

  # Accessible by logged-in user
  # power :user_runtime_selections do
  #   return true if @user.present?
  #   false
  # end

  # Accessible by world
  power :sessions do
    true
  end

  # Accessible by power_users and admins
  power :inventory_txn_filters, :pos_invoices_list_with_payment, :pos_invoice_line_items do
    return true if global_role?
    false
  end

  power :states do
    return State.all if global_role?
    State.none
  end

  power :journal_vouchers do
    return JournalVoucher.all if global_role?
    JournalVoucher.none
  end

  power :business_entity_locations do
    return BusinessEntityLocation.all if global_role?
    get_my_locations
  end

  power :invoices_vouchers do
    return true if global_role?
    false
  end

  power :creatable_pos_invoices do
    true
  end

  power :updatable_pos_invoices do
    return PosInvoice.all if global_role?
    # return PosInvoice.joins(primary_location: :business_entity).where(business_entities: { id: @user.city_id }) if role?('business_entity_location_admin')
    return PosInvoice.joins(:header).where("invoice_headers.business_entity_location_id in (?)", get_my_locations.pluck(:id)) if role?('business_entity_location_admin')
    PosInvoice.joins(:header).where("invoice_headers.business_entity_location_id in (?)", get_my_locations.pluck(:id)).where(created_by_id: @user.id).where("account_txns.created_at > ?", 5.minutes.ago)
  end

  power :view_pos_invoices do
    return PosInvoice.all if global_role?
    # return PosInvoice.joins(primary_location: :business_entity).where(business_entities: { id: @user.city_id }) if role?('business_entity_location_admin')
    # PosInvoice.where(created_by_id: @user.id)
    PosInvoice.joins(:header).where("invoice_headers.business_entity_location_id in (?)", get_my_locations.pluck(:id)) if role?('business_entity_location_admin')
    PosInvoice.joins(:header).where("invoice_headers.business_entity_location_id in (?)", get_my_locations.pluck(:id)).where(created_by_id: @user.id)
  end

  # power :custom_pos_invoices do
  #   return PosInvoice.all if global_role?
  #   return PosInvoice.joins(primary_location: :business_entity).where(business_entities: { id: @user.city_id }) if role?('business_entity_location_admin')
  #   false
  # end

  %w(inventory_out_vouchers inventory_internal_transfer_vouchers inventory_in_vouchers).each do |voucher_type|
    power :"creatable_#{voucher_type}" do
      return true if global_role?
      false
    end

    power :"updatable_#{voucher_type}" do
      return "#{voucher_type}".singularize.camelize.constantize.all if global_role?
      false
    end

    power :"#{voucher_type}_view" do
      return "#{voucher_type}".singularize.camelize.constantize.all if global_role?
      false
    end
  end

  power :inventory_reports do
    return true if global_role?
    false
  end

  power :admin_reports do
    return true if global_role?
    false
  end

  power :reports do
    return true if global_role? || role?('business_entity_location_admin')
    false
  end

  power :creatable_users, :users_view do
    return User.all if global_role?
    false
  end

  power :updatable_users do
    return User.all if global_role?
    User.where(id: @user.id)
  end
end
