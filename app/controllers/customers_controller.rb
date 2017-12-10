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
    # @highest_transaction = Transaction.all.where("date >= ? AND date <= ?", d1, d2).order("coupon_amount DESC").first
    # puts "AAAAAAAAAAAAA@h #{@highest_transaction}"
    # puts @highest_transaction.inspect
    arr ={}
    @customer = Customer.all.each do |c|
      amt = 0
      transctions = c.transactions
      transctions.each do |tra|
         amt += tra.transaction_items.where("date >= ? AND date <= ?", d1, d2).map{|t| t.amount}.try(:sum)
      end
      arr[c.id] = amt
    end
    customer_id = arr.compact.max_by{|k,v| v}
    @customer  = Customer.find_by_id(customer_id[0]) if customer_id

    if(@customer.nil?)
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
        total_spent_amount = c.transactions.where("date >= ? AND date <= ?", from_date, to_date).map{|t| t.total_amount}.inject {|total, t| total + t}
        amt = c.transactions.where("date >= ? AND date <= ?", from_date, to_date).map{|t| t.coupon_amount}.inject {|total, t| total + t}
          v = c.attributes.values_at(*columns) + [total_spent_amount, amt]
          csv << v
        end
        send_file path, filename: file_name
      end
  end

end
