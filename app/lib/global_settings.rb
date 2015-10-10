# values hard-coded for interim use.
# Phase I - These settings can be moved to DB once interface is built for admins to manage it through GUI.
# Phase II - Multi-tenant implementation. Values should be populated based on current user's rights.
class GlobalSettings
  def self.current_bookstall_id
    156
  end

  def self.current_stores_id
    155
  end

  def self.current_business_entitry_id
    136
  end
end
