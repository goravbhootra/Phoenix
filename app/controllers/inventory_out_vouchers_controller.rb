class InventoryOutVouchersController < ApplicationController
  power :inventory_out_vouchers, map:
    {
      [:edit, :update, :get_voucher_sequences, :get_business_entities] => :updatable_inventory_out_vouchers,
      [:new, :create, :get_voucher_sequences, :get_business_entities] => :creatable_inventory_out_vouchers,
      [:index, :show] => :inventory_out_vouchers_view,
      [:destroy] => :destroyable_inventory_out_vouchers
    }, as: :inventory_out_voucher_scope
  include VoucherSequenceable
  include VoucherExtensible
  before_action :set_inventory_out_voucher, only: [:edit, :update, :destroy]

  def index
    @inventory_out_vouchers = inventory_out_voucher_scope.includes(:created_by, [primary_location: :business_entity], :secondary_entity).order("number DESC")

    respond_to do |format|
      format.html
      format.csv { send_data @inventory_out_vouchers.to_csv, filename: "sale_transactions_complete_#{Time.zone.now.in_time_zone.strftime('%Y%m%d')}.csv" }
      format.xls { send_data @inventory_out_vouchers.to_csv(col_sep: "\t"), filename: "sale_transactions_complete_#{Time.zone.now.in_time_zone.strftime('%Y%m%d')}.xls" }
    end
  end

  def show
    @inventory_out_voucher = inventory_out_voucher_scope.includes(:created_by).find(params[:id])
    respond_to do |format|
      format.html
    end
  end

  def new
    @inventory_out_voucher = InventoryOutVoucher.new({voucher_date: Time.zone.now.in_time_zone.strftime('%d/%m/%Y')})
    initialize_form
  end

  def edit
    initialize_form
  end

  def create
    @inventory_out_voucher = InventoryOutVoucher.new(inventory_out_voucher_params.merge!(current_user_id: current_user.id))

    respond_to do |format|
      if @inventory_out_voucher.save
        initialize_form
        format.html { redirect_to @inventory_out_voucher, flash: {success: 'Inventory Out Voucher was created successfully.'}}
        format.json { render :show, status: :created, location: @inventory_out_voucher }
      else
        initialize_form
        format.html { render :new }
        format.json { render json: @inventory_out_voucher.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @inventory_out_voucher.update(inventory_out_voucher_params.merge!(current_user_id: current_user.id))
        format.html { redirect_to @inventory_out_voucher, flash: {success: 'Inventory Out Voucher was updated successfully.'}}
        format.json { render :show, status: :ok, location: @inventory_out_voucher }
      else
        initialize_form
        format.html { render :edit }
        format.json { render json: @inventory_out_voucher.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @inventory_out_voucher.destroy
    respond_to do |format|
      format.html { redirect_to inventory_out_vouchers_url, notice: 'Inventory Out Voucher was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def inventory_out_voucher_params
      params.require(:inventory_out_voucher).permit(:created_by_id, :remarks,
          :tax_amount, :total_amount, :voucher_date, :ref_number, :status, :voucher_sequence_id,
          :goods_value, :primary_location_id, :address, :tax_details, :secondary_entity_id,
          line_items_attributes: [:id, :product_id, :quantity_out, :price, :amount, :tax_rate,
            :_destroy]
        )
      #:tax_amount will be calculated on server-side and not accepted as params
    end

    def set_inventory_out_voucher
      @inventory_out_voucher = inventory_out_voucher_scope.includes(:line_items).find(params[:id])
    end

    def populate_products
      @products ||= Product.includes([:language, :category]).active.order(:sku).load
    end

    def build_child_line_items
      rec_count = @inventory_out_voucher.line_items.size
      if rec_count < 4
        (25 - rec_count).times { @inventory_out_voucher.line_items.build }
      else
        5.times { @inventory_out_voucher.line_items.build }
      end
    end

    def initialize_form
      populate_products
      build_child_line_items
    end
end
