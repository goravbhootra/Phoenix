class VoucherSequencesController < ApplicationController
  before_action :set_voucher_sequence, only: [:edit, :update, :destroy]

  def index
    @voucher_sequences = VoucherSequence.includes(:business_entity).all
  end

  def new
    @voucher_sequence = VoucherSequence.new
  end

  def edit
  end

  def create
    @voucher_sequence = VoucherSequence.new(voucher_sequence_params)

    respond_to do |format|
      if @voucher_sequence.save
        format.html { redirect_to voucher_sequences_url, flash: { success: 'Voucher sequence was successfully created.' } }
        format.json { render :show, status: :created, location: @voucher_sequence }
      else
        format.html { render :new }
        format.json { render json: @voucher_sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @voucher_sequence.update(voucher_sequence_params)
        format.html { redirect_to voucher_sequences_url, flash: { success: 'Voucher sequence was successfully updated.' } }
        format.json { render :show, status: :ok, location: @voucher_sequence }
      else
        format.html { render :edit }
        format.json { render json: @voucher_sequence.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @voucher_sequence.destroy
    respond_to do |format|
      format.html { redirect_to voucher_sequences_url, notice: 'Voucher sequence was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_voucher_sequence
      @voucher_sequence = VoucherSequence.find(params[:id])
    end

    def voucher_sequence_params
      params.require(:voucher_sequence).permit(:business_entity_id, :classification, :number_prefix, :starting_number, :valid_from, :valid_till, :terms_conditions, :active)
    end
end
