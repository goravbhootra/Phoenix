class SessionsController < ApplicationController
  power :sessions, only: [:new, :create, :destroy]

  def new
    build_sign_in
  end

  def create
    build_sign_in
    if @sign_in.save
      user = User.find_by(email: params[:sign_in][:email_id])
      if params[:sign_in][:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        cookies[:auth_token] = user.auth_token
      end
      redirect_to root_url
    else
      render "new"
    end
  end

  def destroy
    if current_user
      current_user.update_attribute(:auth_token, User.reset_auth_token)
      cookies.delete(:auth_token)
      redirect_to root_url, flash: { success: 'Logged out!' }
    else
      redirect_to root_url,  flash: { notice: "Already signed out. Click #{ view_context.link_to('here', login_path) } to login again" }
    end
  end

  private

  def build_sign_in
      @sign_in = SignIn.new(sign_in_params)
  end

  def sign_in_params
      sign_in_params = params[:sign_in]
      sign_in_params.permit(:email_id, :password, :remember_me) if sign_in_params
  end
end
