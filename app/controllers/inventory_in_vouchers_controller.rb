class InventoryInVouchersController < ApplicationController
  power :inventory_in_vouchers, map:
    {
    [:edit, :update, :get_voucher_sequences, :get_business_entities]=> :updatable_inventory_in_vouchers,
    [:new, :create, :get_voucher_sequences, :get_business_entities] => :creatable_inventory_in_vouchers,
    [:index, :show] => :inventory_in_vouchers_view
    }, as: :inventory_in_voucher_scope
  include VoucherSequenceable
  include VoucherExtensible
  before_action :set_inventory_in_voucher, only: [:edit, :update, :destroy]

  def index
    @inventory_in_vouchers = inventory_in_voucher_scope.includes(:created_by, :secondary_entity, [primary_location: :business_entity]).order("number DESC")

    respond_to do |format|
      format.html
      format.csv { send_data @inventory_in_vouchers.to_csv, filename: "purchase_transactions_complete_#{Time.zone.now.in_time_zone.strftime('%Y%m%d')}.csv" }
      format.xls { send_data @inventory_in_vouchers.to_csv(col_sep: "\t"), filename: "purchase_transactions_complete_#{Time.zone.now.in_time_zone.strftime('%Y%m%d')}.xls" }
    end
  end

  def show
    @inventory_in_voucher = inventory_in_voucher_scope.includes(:created_by).find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def new
    @inventory_in_voucher = InventoryInVoucher.new({voucher_date: Time.zone.now.in_time_zone.strftime('%d/%m/%Y')})
    initialize_form
  end

  def edit
    initialize_form
  end

  def create
    @inventory_in_voucher = InventoryInVoucher.new(inventory_in_voucher_params.merge!(current_user_id: current_user.id))

    respond_to do |format|
      if @inventory_in_voucher.save
        initialize_form
        format.html { redirect_to @inventory_in_voucher, flash: { success: 'Inventory In Voucher was created successfully.'} }
        format.json { render :show, status: :created, location: @inventory_in_voucher }
      else
        initialize_form
        format.html { render :new }
        format.json { render json: @inventory_in_voucher.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @inventory_in_voucher.update(inventory_in_voucher_params.merge!(current_user_id: current_user.id))
        format.html { redirect_to @inventory_in_voucher, flash: {success: 'Inventory In Voucher was updated successfully.'}}
        format.json { render :show, status: :ok, location: @inventory_in_voucher }
      else
        initialize_form
        format.html { render :edit }
        format.json { render json: @inventory_in_voucher.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @inventory_in_voucher.destroy
    respond_to do |format|
      format.html { redirect_to inventory_in_vouchers_url, notice: 'Inventory In Voucher was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def inventory_in_voucher_params
      params.require(:inventory_in_voucher).permit(:created_by_id, :remarks,
          :tax_amount, :total_amount, :voucher_date, :ref_number, :status, :voucher_sequence_id,
          :goods_value, :primary_location_id, :address, :tax_details, :secondary_entity_id,
          line_items_attributes: [:id, :product_id, :quantity_in, :price, :amount, :tax_rate,
            :_destroy]
        )
      #:tax_amount will be calculated on server-side and not accepted as params
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_inventory_in_voucher
      @inventory_in_voucher = inventory_in_voucher_scope.includes(:line_items).find(params[:id])
    end

    def populate_products
      @products ||= Product.includes([:language, :category]).active.order(:sku).load
    end

    def build_child_line_items
      rec_count = @inventory_in_voucher.line_items.size
      if rec_count < 4
        (25 - rec_count).times { @inventory_in_voucher.line_items.build }
      else
        5.times { @inventory_in_voucher.line_items.build }
      end
    end

    def initialize_form
      populate_products
      build_child_line_items
    end
end
