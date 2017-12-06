class CustomersController < ApplicationController
  before_action :require_admin_login, only: :index
  before_action :authenticate_user! 

  def get_customer
    mobile = params[:id]
    @c = Customer.find_by_mobile(mobile)
    if(@c.nil?)
     respond_to do |format|
       format.json do
         render json:{:no_data => "true"}
         return
       end
     end
    end
    @t = @c.transactions
    respond_to do |format|
     format.json do
       json = @c.to_json ({:methods => :is_winner?})
       render :json => json
     end
    end
  end
  
  def show
    date = params[:filtered_date]
    if(date)
      d1 = date + " 00:00:00"
      d2 = date + " 23:59:59"
    else
      d1 = Date.today.to_s + " 00:00:00"
      d2 = Date.today.to_s + " 23:59:59"
    end
    mobile = params[:id]
    @selectedDate = date || Date.today
    @c = Customer.find_by_mobile(mobile)
    if(@c.nil?)
      flash[:error] = "Customer doesn't exist"
      redirect_to customers_path 
      return
    end
    @t = @c.transactions
    respond_to do |format|
      format.json do
        json = @c.to_json ({:methods => :is_winner?})
        render :json => json
      end
      format.html do
      
      end
    end
  end

  def index
    date = params[:filtered_date]
    if(date)
      d1 = date + " 00:00:00"
      d2 = date + " 23:59:59"
    else
      d1 = Date.today.to_s + " 00:00:00"
      d2 = Date.today.to_s + " 23:59:59"
    end

    @customers = Customer.all
    @filteredCustomers = Customer.where("id in (select customer_id from transactions where date
                                           >= ? AND date <= ?)", d1, d2)
    # @filteredTrasctions = Customer.includes(:transactions).where("transactions.date >= ? and transactions.date <= ? order by transactions")
    @selectedDate = date || Date.today
    respond_to do |format|
      format.html
      format.csv { send_data @customers.to_csv }
    end
  end

  def get_highest_shopper
    d1 = Date.today.to_s + " 00:00:00"
    d2 = Date.today.to_s + " 23:59:59"
    @highest_transaction = Transaction.all.where("date >= ? AND date <= ?", d1, d2).order("coupon_amount DESC").first
    puts @highest_transaction.inspect
    @customer = Customer.find_by_id(@highest_transaction.customer_id ) if @highest_transaction
    if(@customer.nil? || @highest_transaction.nil?)
      respond_to do |format|
        format.json do
          render json:{:no_data => "true"}
          return
        end
      end
    end
    respond_to do |format|
      format.json do
        json = @customer.to_json
        render :json => json
      end
    end
  end

  def filter_by_date
    body = JSON.parse(request.body.read)
    puts body
    puts body["date"]
    @customers = Customer.includes(:transactions).where("transactions.date" =>body["date"])
    render "index"
  end

  def csv_download
    from_date = params[:from_date] + " 00:00:00"
    to_date = params[:to_date] + " 23:59:59"
    all = Transaction.all.where("date >= ? AND date <= ?", from_date, to_date)
    file = Tempfile.new("Customers#{Time.now.to_f}.csv")
    file_name = "Customers(#{Time.now.strftime("%a %b %d %Y %H:%M:%S")}).csv"
    path = file.path
    @filteredCustomers = Customer.where("id in (select customer_id from transactions where date
                                           >= ? AND date <= ?)", from_date, to_date)

    CSV.open(path, "w") do |csv|
      columns = Customer.customer_column_names
      csv << columns + ["total_spent", "coupon_amount"]
      @filteredCustomers.all.each do |c|
        amt = c.transactions.where("date >= ? AND date <= ?", from_date, to_date).map{|t| t.coupon_amount}.inject {|total, t| total + t}
          v = c.attributes.values_at(*columns) + [c.total_spent_by_customer, amt]
          csv << v
        end
        send_file path, filename: file_name
      end
  end

end
