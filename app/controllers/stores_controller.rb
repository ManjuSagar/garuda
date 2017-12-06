class StoresController < ApplicationController
  require 'csv'
  before_action :require_admin_login
  before_action :authenticate_user! 
   
  def new 

  end
  
  def create
    store_name = params[:storeName]
    
    if(store_name.nil? or store_name.strip.empty?)
      flash[:error] = 'Please enter store name!'
      redirect_to new_store_path
      return
    end

    store = Store.new(name: store_name.strip)

    begin 
      store.save!
    rescue ActiveRecord::RecordInvalid => e

      store.errors.to_a.each do |e|
        if(e == "Name has already been taken")
          flash[:error] = "Store already exists."
          redirect_to new_store_path
          return
        end
      end

      raise e
      
    end
    
    flash[:notice] = 'Store Name updated succesfully.'
    redirect_to stores_path
    return
  end

  def index
    @stores = Store.order("id").paginate(:page => params[:page], :per_page => 20)
  end

  def show
   store_id = params[:id]
   @store = Store.find_by_id(store_id)
   if(@store.nil?)
    render :nothing => true, :status => :not_found
    return
   end
   @transaction_items = TransactionItem.where(store_id: store_id).paginate(:page => params[:page], :per_page => 20) 
  end

  def import
    file = params[:file]
    if(file)
      CSV.foreach(file.path, headers: true, :encoding => 'ISO-8859-1') do |row|
        next if row == nil
        name = row.try(:strip)
        Store.find_or_create_by(name: row.to_s)
      end
    end
    redirect_to stores_path
  end

end
