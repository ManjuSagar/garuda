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
      # d1 = Date.today.to_s + " 00:00:00"
      # d2 = Date.today.to_s + " 23:59:59"
    end

    @customers = Customer.all
    @filteredCustomers = Customer.where("id in (select customer_id from transactions where date
                                           >= ? AND date <= ?)", d1, d2)
    # @filteredTrasctions = Customer.includes(:transactions).where("transactions.date >= ? and transactions.date <= ? order by transactions")
    @selectedDate = date
    respond_to do |format|
      format.html
      format.csv { send_data @customers.to_csv }
    end
  end

  def list_silver_customers
    @valid_customers = Customer.silver_eligble_customers_for_the_day || []
    @valid_customers  
  end  

  def top_five_customers
    @valid_customers = Customer.get_top_customers(5)
    puts("Valid customerssssssssss #{@valid_customers.inspect}")
    render :list_silver_customers
  end

  def issue_silver
    @customer = Customer.find(params[:id])
    unless @customer.got_silver?
      @customer.got_silver = true
      @customer.save!
      redirect_to :action => :list_silver_customers  
    end
  end 

  def get_highest_shopper
    # d1 = Date.today.to_s + " 00:00:00"
    # d2 = Date.today.to_s + " 23:59:59"
    # @highest_transaction = Transaction.all.where("date >= ? AND date <= ?", d1, d2).order("coupon_amount DESC").first
    # puts "AAAAAAAAAAAAA@h #{@highest_transaction}"
    # puts @highest_transaction.inspect
    @customer = Customer.get_top_customers(1)
    #@customer = ActiveRecord::Base.connection.execute(sql)
    if (@customer.count > 0)
      respond_to do |format|
        format.json do
          json = @customer
          render :json => json
        end
      end
    else 
      respond_to do |format|
        format.json do
          render json:{:no_data => "true"}
          return
        end
      end
    end

    # arr ={}
    # @customer = Customer.all.includes(:transactions).each do |c|
    
    #   #manju commentd
    #   #transction_amt = c.transactions.where("date >= ? AND date <= ?", d1, d2).map{|t| t.coupon_amount}.try(:sum)
    #   transction_amt = c.transactions.map{|t| t.coupon_amount}.try(:sum)
    #   # transctions.each do |tra|
    #   #    amt += tra.transaction_items.where("date >= ? AND date <= ?", d1, d2).map{|t| t.amount}.try(:sum)
    #   # end
    #   arr[c.id] = transction_amt
    # end
    # customer_id = arr.compact.max_by{|k,v| v}
    # @customer  = Customer.find_by_id(customer_id[0]) if customer_id

    # if(@customer.nil?)
    #   respond_to do |format|
    #     format.json do
    #       render json:{:no_data => "true"}
    #       return
    #     end
    #   end
    # end
    # respond_to do |format|
    #   format.json do
    #     json = @customer.to_json
    #     render :json => json
    #   end
    # end
  end

  def filter_by_date
    body = JSON.parse(request.body.read)
    puts body
    puts body["date"]
    @customers = Customer.includes(:transactions).where("transactions.date" =>body["date"])#.order(coupon_amount: :desc)
    render "index"
  end

  def csv_download
    from_date = Time.parse(params[:from_date]).utc
    to_date = Time.parse(params[:to_date]).utc
    all = Transaction.all.where("created_at >= ? AND created_at <= ?", from_date, to_date)
    file = Tempfile.new("Customers#{Time.now.to_f}.csv")
    file_name = "Customers(#{Time.now.strftime("%a %b %d %Y %H:%M:%S")}).csv"
    path = file.path
    @filteredCustomers = Customer.where("id in (select customer_id from transactions where created_at
                                           >= ? AND created_at <= ?)", from_date, to_date)

    CSV.open(path, "w") do |csv|
      columns = Customer.customer_column_names
      csv << columns + ["total_spent", "coupon_amount", "vouchers"]
      @filteredCustomers.all.each do |c|
        vouchers = c.transactions.includes(:vouchers).pluck("vouchers.barcode_number")
        vouchers = vouchers.join("- ") if vouchers.present?
        total_spent_amount = c.transactions.where("created_at >= ? AND created_at <= ?", from_date, to_date).map{|t| t.total_amount}.inject {|total, t| total + t}
        amt = c.transactions.where("created_at >= ? AND created_at <= ?", from_date, to_date).map{|t| t.coupon_amount}.inject {|total, t| total + t}
          v = c.attributes.values_at(*columns) + [total_spent_amount, amt, vouchers]
          csv << v
        end
        send_file path, filename: file_name
      end
  end

  def silver_winners
    #from_date = params[:from_date]
    #to_date = params[:to_date]
    from_date = Time.parse(params[:from_date]).utc
    to_date = Time.parse(params[:to_date]).utc
    #all = Transaction.all.where("date >= ? AND date <= ? AND total_sum >= 3000", from_date, to_date)
    file = Tempfile.new("Silver_Customers#{Time.now.to_f}.csv")
    file_name = "Silver_Customers(#{Time.now.strftime("%a %b %d %Y %H:%M:%S")}).csv"
    path = file.path
    @filteredCustomers = Customer.where("id in (select customer_id from transactions where created_at >= ? AND created_at <= ?)", from_date, to_date)

    CSV.open(path, "w") do |csv|
      columns = Customer.customer_column_names
      csv << columns + ["total_spent", "coupon_amount", "vouchers"]
      @filteredCustomers.all.each do |c|
        vouchers = c.transactions.includes(:vouchers).pluck("vouchers.barcode_number")
        vouchers = vouchers.join("- ") if vouchers.present?
        total_spent_amount = c.transactions.where("created_at >= ? AND created_at <= ?", from_date, to_date).map{|t| t.total_amount}.inject {|total, t| total + t}
        amt = c.transactions.where("created_at >= ? AND created_at <= ? ", from_date, to_date).map{|t| t.coupon_amount}.inject {|total, t| total + t}
          v = c.attributes.values_at(*columns) + [total_spent_amount, amt, vouchers]
          csv << v
        end
        send_file path, filename: file_name
      end
  end

end
