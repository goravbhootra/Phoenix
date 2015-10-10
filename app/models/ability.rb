class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    power = Power.new(user)
    if power.global_role? && power.role?('admin')
      can :manage, :all
      can :account_cash_account, :all
      can :account_bank_account, :all
    elsif power.global_role? && power.role?('power_user')
      can :access, :rails_admin
      can :dashboard
      # Performed checks for `collection` scoped actions:
      can :index, :all         # included in :read
      can :new, :all           # included in :create
      # can :history, Model       # for HistoryIndex
      # can :destroy, Model       # for BulkDelete

      # Performed checks for `member` scoped actions:
      can :show, :all            # included in :read
      can :edit, Product            # included in :update
      can :edit, ProductGroup
      # can :edit, Member
      can :edit, User
      can :edit, Author
      can :edit, Category
      can :edit, CoreLevel
      can :edit, DistributionType
      can :edit, FocusGroup
      can :edit, Language
      can :edit, StateCategoryTaxRate
      can :edit, Uom
      can :edit, Region
      can :edit, Zone
      can :edit, State
      can :edit, City
      can :edit, BusinessEntity
      can :edit, VoucherSequence
      cannot :show, Role
      cannot :edit, Role
      cannot :show, UserRole
      cannot :edit, UserRole
    else
      cannot :access, :rails_admin
      cannot :dashboard
      cannot :index, :all
    end
  end
end
