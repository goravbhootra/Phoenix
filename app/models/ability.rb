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
      # can :destroy, Model, object         # for Delete
      # can :history, Model, object         # for HistoryShow
      # can :show_in_app, Model, object
    else
      # (user.roles & [:user]).present?
      cannot :access, :rails_admin
      cannot :dashboard
      cannot :index, :all
    end
  end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
end
