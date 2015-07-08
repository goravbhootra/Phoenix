class ApplicationController < ActionController::Base
  include Consul::Controller
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate
  before_action :current_ability

  helper_method :current_user
  helper_method :current_business_entity

  # require_power_check
  current_power do
    Power.new(current_user)
  end

  rescue_from Consul::Powerless do
    flash[:notice] = "Access Restricted. Contact Admin for further assistance."
    begin
      redirect_to(:back)
    rescue ActionController::RedirectBackError
      redirect_to root_url
    end
  end

  def current_ability
    @current_ability ||= Ability.new(current_user)
  end

  rescue_from CanCan::AccessDenied do
    flash[:notice] = "Access Restricted. Contact Admin for further assistance."
    begin
      redirect_to(:back)
    rescue ActionController::RedirectBackError
      redirect_to main_app.root_url
    end
  end

  def current_business_entity
    @current_business_entity = BusinessEntity.where(id: params[:current_business_entity_id].to_i).first if params[:current_business_entity_id].present?
    render text: ''
  end

  private

  def current_user
    @current_user ||= User.active.find_by(auth_token: (cookies[:auth_token])) if cookies[:auth_token]
    if @current_user.present?
      current_power = Power.new(@current_user)
      @business_entities ||= current_power.get_my_business_entities.pluck(:id, :alias_name).to_h.invert
    end
      # @entity_locations ||= BusinessEntityLocation.active.map { |location| [location.business_entity_name_with_location, location.id] }
    @current_user
  end

  # def rails_admin_authenticate
  #   RailsAdmin.authorize_with do
  #     redirect_to main_app.root_url unless current_user
  #   end
  # end

  def authenticate
    unless current_user
      begin
        redirect_to root_url, :flash => { :error => "Please login" } if params[:controller] != "sessions"
      rescue ActionController::UrlGenerationError
        redirect_to main_app.root_url, alert: 'Please login'
      end
    end
  end

  # def current_business_entity
  #   @current_business_entity ||= current_user.business_entities.find(session[:company_id])
  # end
end
