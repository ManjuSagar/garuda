class VouchersController < ApplicationController
  before_action :require_admin_login

  def index
    @vouchers = Voucher.all
    respond_to do |format|
      format.html
      format.csv { send_data @vouchers.to_csv }
    end
  end

  def show
    id = params[:id]
    @voucher = Voucher.find_by_barcode_number id
    if(@voucher.nil?)
      flash[:error] = "Coupon #{id} doesn't exist"
      redirect_to vouchers_path
      return
    end
    @transaction = @voucher.transact
    @voucher_master_details = @voucher.voucher_master
    @transaction_items = @transaction.transaction_items
    @customer = @transaction.customer
  end
end