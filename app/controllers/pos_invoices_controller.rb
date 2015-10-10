class PosInvoicesController < ApplicationController
  power :pos_invoices, map: {
                          [:edit, :update, :get_voucher_sequences] => :updatable_pos_invoices,
                          [:new, :create, :get_voucher_sequences] => :creatable_pos_invoices,
                          [:index, :show] => :view_pos_invoices,
                          [:destroy] => :destroyable_pos_invoices
                        }, as: :pos_invoice_scope
  include VoucherSequenceable
  before_action :set_pos_invoice, only: [:edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html
      # format.csv { send_data @pos_invoices.to_csv, filename: "sale_transactions_complete_#{Time.zone.now.in_time_zone.strftime('%Y%m%d')}.csv" }
      format.xls #{ send_data @pos_invoices.to_csv(col_sep: "\t"), filename: "sale_transactions_complete_#{Time.zone.now.in_time_zone.strftime('%Y%m%d')}.xls" }
      format.json { render json: PosInvoiceDatatable.new(view_context) }
    end
  end

  def show
    @pos_invoice = pos_invoice_scope.includes([line_items: [product: :language]], :created_by).find(params[:id])
    respond_to do |format|
      format.html #{ redirect_to pos_invoice(@pos_invoice.id) }
      format.pdf do
        pdf = PosInvoicePdf.new(@pos_invoice)
        send_data pdf.render, filename: "pos_invoice_#{@pos_invoice.number}",
                              type: "application/pdf",
                              disposition: 'inline'
      end
    end
  end

  def new
    @pos_invoice = PosInvoice.new({txn_date: Time.zone.now.in_time_zone.strftime('%d/%m/%Y')})
    initialize_form
  end

  def edit
    initialize_form
  end

  def create
    @pos_invoice = PosInvoice.new(pos_invoice_params.merge!(current_user_id: current_user.id))#, current_business_entity: current_business_entity))

    respond_to do |format|
      if @pos_invoice.save
        if params[:save_and_print].present?
          pos_invoice_url(@pos_invoice, url: pos_invoice_url, format: "pdf")
          @pos_invoice.render_pdf_to_file(Rails.root.join('tmp','pdf',"#{@pos_invoice.id}.pdf"))
          format.html { redirect_to @pos_invoice, url: pos_invoice_url, notice: 'POS invoice created and printed.' }
          # format.html { redirect_to "/#{pos_invoices_url}/#{@pos_invoice.id}?save_and_print=1", notice: 'Invoice  has been saved and printed.' }
        else
          initialize_form
          # Temp workaround, this needs to be changed.
          # format.html { redirect_to pos_invoice_path(@pos_invoice.id), flash: {success: 'POS invoice was created successfully.'}}
          format.html { redirect_to pos_invoice_path(@pos_invoice.id) }
          format.json { render :show, status: :created, location: @pos_invoice }
        end
      else
        initialize_form
        format.html { render :new }
        format.json { render json: @pos_invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @pos_invoice.update(pos_invoice_params.merge!(current_user_id: current_user.id))
        format.html { redirect_to pos_invoice_url(@pos_invoice.id), flash: {success: 'POS invoice was updated successfully.'}}
        format.json { render :show, status: :ok, location: @pos_invoice }
      else
        initialize_form
        format.html { render :edit }
        format.json { render json: @pos_invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @pos_invoice.destroy_with_children
    respond_to do |format|
      format.html { redirect_to pos_invoices_url, notice: 'POS invoice was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  def pos_invoice_params
    params.require(:pos_invoice).permit(:business_entity_id, :currency_id,
                                        :voucher_sequence_id, :created_by_id,
                                        :remarks, :txn_date, :status, :ref_number,
                                        debit_entries_attributes: [:id, :account_id, :amount,
                                          :remarks, :bank_name, :card_last_digits,
                                          :expiry_month, :expiry_year, :mobile_number,
                                          :card_holder_name, :_destroy, :mode],
                                        credit_entries_attributes: [:id, :account_id, :amount,
                                          :remarks, :bank_name, :card_last_digits,
                                          :expiry_month, :expiry_year, :mobile_number,
                                          :card_holder_name, :_destroy],
                                        header_attributes: [:id, :address, :legal_details,
                                          :customer_membership_number,
                                          :business_entity_location_id],
                                        line_items_attributes: [:id, :product_id,
                                          :quantity, :price, :goods_value, :tax_rate,
                                            :tax_amount, :amount,:state_category_tax_rate_id,
                                            :_destroy]
                                         )
    #:tax_amount is not included in pos_invoice or line_items as it will be calculated by server
  end

  def set_pos_invoice
    @pos_invoice = pos_invoice_scope.includes(:line_items, :header, :debit_entries, :credit_entries).find(params[:id])
  end

  def populate_tax_slabs
  end

  def populate_products
    @products ||= Product.includes([:language, :category]).active.order(:sku)
  end

  def build_child_line_items
    rec_count = @pos_invoice.line_items.size
    if rec_count < 4
      (15 - rec_count).times { @pos_invoice.line_items.build }
    else
      4.times { @pos_invoice.line_items.build }
    end
  end

  def build_payment_children
    user_cash_account_id = current_user.cash_account_id

    debit_payments = @pos_invoice.debit_entries.payment_entries
    if debit_payments.blank? || debit_payments.collect(&:mode).exclude?('Account::CashAccount')
        @pos_invoice.debit_entries.build(account_id: current_user.cash_account_id, mode: current_user.cash_account.type) if current_user.cash_account_id.present?
    end
    if debit_payments.blank? || debit_payments.collect(&:mode).exclude?('Account::BankAccount')
      @pos_invoice.debit_entries.build(account_id: BusinessEntityLocation.find(GlobalSettings.current_bookstall_id).bank_account_id, mode: BusinessEntityLocation.find(GlobalSettings.current_bookstall_id).bank_account.type) if BusinessEntityLocation.find(GlobalSettings.current_bookstall_id).bank_account_id.present?
    end

    credit_payments = @pos_invoice.credit_entries.payment_entries
    if credit_payments.blank? || credit_payments.collect(&:mode).exclude?('Account::CashAccount')
      @pos_invoice.credit_entries.build(account_id: current_user.cash_account_id, mode: current_user.cash_account.type) if current_user.cash_account_id.present?
    end
  end

  def build_header
    @pos_invoice.build_header(business_entity_location_id: GlobalSettings.current_bookstall_id) if @pos_invoice.header.blank?
  end

  def initialize_form
    populate_tax_slabs
    populate_products
    build_header
    build_child_line_items
    build_payment_children
  end
end
