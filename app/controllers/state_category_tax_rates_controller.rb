class StateCategoryTaxRatesController < ApplicationController
  before_action :set_state_category_tax_rate, only: [:show, :edit, :update, :destroy]

  # GET /state_category_tax_rates
  # GET /state_category_tax_rates.json
  def index
    @state_category_tax_rates = StateCategoryTaxRate.all
  end

  # GET /state_category_tax_rates/1
  # GET /state_category_tax_rates/1.json
  def show
  end

  # GET /state_category_tax_rates/new
  def new
    @state_category_tax_rate = StateCategoryTaxRate.new
  end

  # GET /state_category_tax_rates/1/edit
  def edit
  end

  # POST /state_category_tax_rates
  # POST /state_category_tax_rates.json
  def create
    @state_category_tax_rate = StateCategoryTaxRate.new(state_category_tax_rate_params)

    respond_to do |format|
      if @state_category_tax_rate.save
        format.html { redirect_to @state_category_tax_rate, notice: 'State category tax rate was successfully created.' }
        format.json { render :show, status: :created, location: @state_category_tax_rate }
      else
        format.html { render :new }
        format.json { render json: @state_category_tax_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /state_category_tax_rates/1
  # PATCH/PUT /state_category_tax_rates/1.json
  def update
    respond_to do |format|
      if @state_category_tax_rate.update(state_category_tax_rate_params)
        format.html { redirect_to @state_category_tax_rate, notice: 'State category tax rate was successfully updated.' }
        format.json { render :show, status: :ok, location: @state_category_tax_rate }
      else
        format.html { render :edit }
        format.json { render json: @state_category_tax_rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /state_category_tax_rates/1
  # DELETE /state_category_tax_rates/1.json
  def destroy
    @state_category_tax_rate.destroy
    respond_to do |format|
      format.html { redirect_to state_category_tax_rates_url, notice: 'State category tax rate was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_state_category_tax_rate
      @state_category_tax_rate = StateCategoryTaxRate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def state_category_tax_rate_params
      params.require(:state_category_tax_rate).permit(:state_id, :category_id, :classification, :interstate_label, :interstate_rate, :intrastate_label, :intrastate_rate, :valid_from, :valid_till, :active)
    end
end
