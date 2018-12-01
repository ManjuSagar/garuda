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

  def csv_download
    #all = TransactionItem.all.where("date >= ? AND date <= ?", params[:from_date], params[:to_date])
    d1 = params[:from_date]
    d2 = params[:to_date]
    sql = "select SUM(t.amount), s.id, s.name from stores s INNER JOIN transaction_items t ON t.store_id = s.id where t.date >='"+ d1 + "' and t.date <= '" + d2 + "' GROUP BY s.id;"
    all = ActiveRecord::Base.connection.execute(sql)
    file = Tempfile.new("Stores_items#{Time.now.to_f}.csv")
    file_name = "Stores_items(#{Time.now.strftime("%a %b %d %Y %H:%M:%S")}).csv"
    path = file.path

    CSV.open(path, "w") do |csv|
      columns = ["id"] + ["Name"] + ["Total bill amount"] 
      csv <<  columns
      all.each do |c|
        v = [c['id']] + [c['name']] +[c['sum']]
        csv << v
      end
      send_file path, filename: file_name
    end
  end

end
