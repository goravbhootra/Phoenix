class StatesController < ApplicationController
  power :states, as: :state_scope
  before_action :set_state, only: [:show, :edit, :update, :destroy]

  def index
    @states = state_scope
  end

  def show
  end

  def new
    @state = State.new
  end

  def edit
  end

  def create
    @state = State.new(state_params)

    respond_to do |format|
      if @state.save
        format.html { redirect_to @state, notice: 'State was successfully created.' }
        format.json { render :show, status: :created, location: @state }
      else
        format.html { render :new }
        format.json { render json: @state.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @state.update(state_params)
        format.html { redirect_to @state, notice: 'State was successfully updated.' }
        format.json { render :show, status: :ok, location: @state }
      else
        format.html { render :edit }
        format.json { render json: @state.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @state.destroy
    respond_to do |format|
      format.html { redirect_to states_url, notice: 'State was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_state
      @state = state_scope.find(params[:id])
    end

    def state_params
      params.require(:state).permit(:name, :region_id, :code, :active)
    end
end
