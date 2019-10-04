class TransactionItemsController < ApplicationController
  require 'csv'
  before_action :require_admin_login

  def index
    @transaction_items = TransactionItem.all
    respond_to do |format|
      format.html
      format.csv { send_data @transaction_items.to_csv }
    end
  end

  def csv_download
    from_date = Time.parse(params[:from_date]).utc
    to_date = Time.parse(params[:to_date]).utc
    all = TransactionItem.all.where("created_at >= ? AND created_at <= ?", from_date, to_date)
    file = Tempfile.new("Transaction_items#{Time.now.to_f}.csv")
    file_name = "Transaction_items(#{Time.now.strftime("%a %b %d %Y %H:%M:%S")}).csv"
    path = file.path

    CSV.open(path, "w") do |csv|
      columns = ["id"] + ["transaction_id"] + ["bill_no"] + ["store_name"]+ ["items count"]+ ["amount"]  + ["Jwells"] + ["Customer Name"] + ["Mobile"] + ["Email"] + ["Is winner"] + ["Got silver"] + ["Date"]
      csv <<  columns
      all.each do |c|
        customer = c.transact.customer
        v = [c.id] + [c.transaction_id] +[c.item_id] + [c.store.name] + [c.items_count] + [c.amount] + [c.is_jwells] + [customer.name] + [customer.mobile] + [customer.email] + [customer.is_winner] + [customer.got_silver] + [c.created_at.in_time_zone('Chennai')]
        csv << v
      end
      send_file path, filename: file_name
    end
  end


end