class WinnersController < ApplicationController
  before_action :require_admin_login

  def new
  end

  def create
    number = params[:number]
    datetime = params["datetime-local"]
    parsed_date = DateTime.parse(datetime)
    date = parsed_date.strftime("%Y-%m-%d %H:00:00")
    # date = datetime.split('T')[0]
    # hour = datetime.split('T')[1][0..1]
    customer = nil
    already_winned_customer = Customer.find_by_winning_date(date)

    puts("Already wonnnnnnn #{already_winned_customer}")
   
    if(already_winned_customer)
       flash[:error] = 'Already one Customer has won in this Date and Time,'
      redirect_to new_winner_path
      return
    end

    # voucher = Voucher.find_by_barcode_number number 
    customer = Customer.find_by_mobile number
    # if (customer)
    # #   customer_id = voucher.transact.customer_id
    #   # customer = Customer.find customer_id
    # else  
    #   flash[:error] = 'Not a valid Customer.'
    #   redirect_to new_winner_path
    # end  

    #customer = Customer.find_by_mobile number

    # if(!v.nil?)
    #   flash[:error] = 'Winner has already been selected for today.'
    #   redirect_to new_transaction_path
    #   return
    # end

    # v = Voucher.find_by_barcode_number voucher_barcode
    #
     puts "vvvvvvvvvvvvvvvvvvvvvvvvvvv #{customer.inspect}"

    if(customer.nil?)
      flash[:error] = 'Customer does not exist with this number.'
      redirect_to new_winner_path
      return
    end

    if(!customer.nil? && customer.winning_date.present? && customer.winning_date.day == parsed_date.day ) #Winning Date check for current day 
      flash[:error] = 'This Customer has already won Today.'
      redirect_to new_winner_path
      return
    end



    customer.mark_as_winner(date, number)
    customer.save!



    flash[:notice] = 'Winner updated succesfully.'
    redirect_to new_winner_path #transaction_path v.transact.id
  end

  def csv_download
    from_date = params[:from_date]
    to_date = params[:to_date]
    all = Customer.all.where("winning_date >= ? AND winning_date <= ?", from_date, to_date)
    file = Tempfile.new("Customers_#{Time.now.to_f}.csv")
    file_name = "Customers(#{Time.now.strftime("%a %b %d %Y %H:%M:%S")}).csv"
    path = file.path

    CSV.open(path, "w") do |csv|
      columns = ["id"] + ["Name"] + ["Mobile"] + ["Winning Date"] + ["Email"] + ["Total Coupon value"] + ["Total Purchase value"] + ["Coupon"]
      csv <<  columns
      all.each do |c|
        v = [c.id] + [c.name] +[c.mobile] + [c.winning_date] + [c.email] + [c.transactions.sum(:coupon_amount)] + [c.transactions.sum(:total_sum)] + [c.winning_bar_code] 
        csv << v
      end
      send_file path, filename: file_name
    end
  end
end