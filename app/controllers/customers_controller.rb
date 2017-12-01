class CustomersController < ApplicationController
  before_action :require_admin_login, only: :index
  before_action :authenticate_user! 

  def get_customer
    mobile = params[:id]
    puts Customer.last.inspect
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
end