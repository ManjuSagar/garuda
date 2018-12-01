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

  def csv_download
    from_date = params[:from_date] + " 00:00:00"
    to_date = params[:to_date] + " 23:59:59"
    all = Voucher.all.where("created_at >= ? AND created_at <= ?", from_date, to_date)
    file = Tempfile.new("Vouchers_#{Time.now.to_f}.csv")
    file_name = "Vouchers(#{Time.now.strftime("%a %b %d %Y %H:%M:%S")}).csv"
    path = file.path

    CSV.open(path, "w") do |csv|
      columns = ["id"] + ["barcode_number"] + ["transaction_id"] 
      csv <<  columns
      all.each do |c|
        v = [c.id] + [c.barcode_number] +[c.transaction_id]
        csv << v
      end
      send_file path, filename: file_name
    end
  end
end