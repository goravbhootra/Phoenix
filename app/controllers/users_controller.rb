class UsersController < ApplicationController
  power :users, map: {
                        [:edit, :update] => :updatable_users,
                        [:new, :create] => :creatable_users,
                        [:index, :show] => :users_view
                      }, as: :user_scope

  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
    @cities ||= City.active
  end

  def edit
    @cities ||= City.active
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        @cities ||= City.active
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        if current_user.role?(['admin','power_user'])
          format.html { redirect_to users_url, flash: {success: 'User profile was successfully updated.' } }
          format.json { render :show, status: :ok, location: @user }
        else
          format.html { redirect_to root_url, flash: {success: 'Profile was successfully updated.' } }
        end
      else
        @cities ||= City.active
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :contact_number_primary, :contact_number_secondary, :address, :active, :confirmed, :roles, :city_id, :membership_number)
    end
end
