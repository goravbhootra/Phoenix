class JournalVouchersController < ApplicationController
  power :journal_vouchers, as: :journal_voucher_scope
  before_action :set_journal_voucher, only: [:show, :edit, :update, :destroy]

  def index
    @journal_vouchers = JournalVoucher.all
  end

  def show
  end

  def new
    @journal_voucher = JournalVoucher.new({txn_date: Time.zone.now.in_time_zone.strftime('%d/%m/%Y')})
    build_debit_credit_children
  end

  def edit
    build_debit_credit_children
  end

  def create
    @journal_voucher = JournalVoucher.new(journal_voucher_params.merge!(current_user_id: current_user.id))

    respond_to do |format|
      if @journal_voucher.save
        format.html { redirect_to @journal_voucher, flash: {success: 'Journal Voucher created successfully.'}}
        format.json { render :show, status: :created, location: @journal_voucher }
      else
        build_debit_credit_children
        format.html { render :new }
        format.json { render json: @journal_voucher.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @journal_voucher.update(journal_voucher_params)
        format.html { redirect_to @journal_voucher, flash: {success: 'Journal Voucher updated successfully.'}}
        format.json { render :show, status: :ok, location: @journal_voucher }
      else
        build_debit_credit_children
        format.html { render :edit }
        format.json { render json: @journal_voucher.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @journal_voucher.destroy
    respond_to do |format|
      format.html { redirect_to journal_vouchers_url, notice: 'Account txn was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_journal_voucher
      @journal_voucher = journal_voucher_scope.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def journal_voucher_params
      params.require(:journal_voucher).permit(:business_entity_id, :currency_id,
                                        :voucher_sequence_id, :created_by_id,
                                        :remarks, :txn_date, :status, :ref_number,
                                        debit_entries_attributes: [:id, :account_id, :amount,
                                          :remarks, :_destroy, :mode],
                                        credit_entries_attributes: [:id, :account_id, :amount,
                                          :remarks, :_destroy]
                                         )
    end

    def build_debit_credit_children
      4.times do
        @journal_voucher.debit_entries.build
        @journal_voucher.credit_entries.build
      end
    end
end
