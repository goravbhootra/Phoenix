class Power
  include Consul::Power

  def initialize(user)
    @user = user
    @roles = user.roles.pluck(:name, :id).to_h if user
  end

  def role?(roles=@roles)
    (@roles.keys & Array(roles)).present?
  end

  def global_role?
    role?(['admin', 'power_user', 'hq_staff'])
  end

  def get_my_locations
    return BusinessEntityLocation.where(active: true) if global_role?
    entities_and_locs = @user.user_roles.where("business_entity_id IS NOT NULL OR business_entity_location_id IS NOT NULL").pluck(:business_entity_id, :business_entity_location_id)
    BusinessEntityLocation.where('business_entity_id in (?) OR business_entity_locations.id in (?)', BusinessEntity.where(id: entities_and_locs.transpose[0].compact).pluck('DISTINCT id'), entities_and_locs.transpose[1].compact.uniq) if entities_and_locs.present?
  end

  def get_my_business_entities
    return BusinessEntity.where(active: true) if global_role?
    entities_and_locs = @user.user_roles.where("business_entity_id IS NOT NULL OR business_entity_location_id IS NOT NULL").pluck(:business_entity_id, :business_entity_location_id)
    BusinessEntity.where('id in (?) OR id in (?)', entities_and_locs.transpose[0].compact.uniq, BusinessEntityLocation.where(id: entities_and_locs.transpose[1].compact.uniq).pluck('DISTINCT business_entity_id')) if entities_and_locs.present?
  end

  # Accessible by world
  power :sessions do
    true
  end

  # Accessible by power_users and admins
  power :inventory_txn_filters, :pos_invoices_list_with_payment, :pos_invoice_line_items, :inventory_internal_transfer_vouchers_line_items, :products do
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

  power :updatable_pos_invoices, :destroyable_pos_invoices do
    return PosInvoice.all if global_role?
    return PosInvoice.joins(:header).where("invoice_headers.business_entity_location_id in (?)", get_my_locations.pluck(:id)) if role?('business_entity_location_admin')
    PosInvoice.joins(:header).where("invoice_headers.business_entity_location_id in (?)", get_my_locations.pluck(:id)).where(created_by_id: @user.id).where("account_txns.created_at > ?", 5.minutes.ago)
  end

  power :destroyable_pos_invoice? do |invoice|
    return true if global_role?
    return true if role?('business_entity_location_admin') && PosInvoice.joins(:header).where("invoice_headers.business_entity_location_id in (?)", get_my_locations.pluck(:id)).includes?(invoice.id)
    false
  end

  power :view_pos_invoices do
    return PosInvoice.all if global_role?
    PosInvoice.joins(:header).where("invoice_headers.business_entity_location_id in (?)", get_my_locations.pluck(:id)) if role?('business_entity_location_admin')
    PosInvoice.joins(:header).where("invoice_headers.business_entity_location_id in (?)", get_my_locations.pluck(:id)).where(created_by_id: @user.id)
  end

  %w(inventory_out_vouchers inventory_internal_transfer_vouchers inventory_in_vouchers).each do |voucher_type|
    power :"#{voucher_type}_view" do
      return "#{voucher_type}".singularize.camelize.constantize.all if global_role?
      false
    end

    power :"creatable_#{voucher_type}" do
      return true if global_role?
      false
    end

    power "updatable_#{voucher_type}".to_sym, "destroyable_#{voucher_type}".to_sym do
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
