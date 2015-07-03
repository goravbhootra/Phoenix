class UsersController < ApplicationController
  power :users, map: {
                        [:edit, :update] => :updatable_users,
                        [:new, :create] => :creatable_users,
                        [:index, :show] => :users_view
                      }, as: :user_scope

  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
    @cities ||= City.active
  end

  # GET /users/1/edit
  def edit
    @cities ||= City.active
  end

  # POST /users
  # POST /users.json
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

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        if current_user.role?(['admins','power_user'])
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

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :contact_number_primary, :contact_number_secondary, :address, :active, :confirmed, :roles, :city_id, :membership_number)
    end
end
