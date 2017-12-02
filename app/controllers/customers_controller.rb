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
    mobile = params[:id]
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
    @customers = Customer.all
    respond_to do |format|
      format.html
      format.csv { send_data @customers.to_csv }
    end
  end

  def get_highest_shopper
    d = DateTime.now.beginning_of_day
    @highest_transaction = Transaction.all.where("date >=?", d).order("coupon_amount DESC").first
    puts @highest_transaction.inspect
    @customer = Customer.find_by_id(@highest_transaction.customer_id)
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

end
