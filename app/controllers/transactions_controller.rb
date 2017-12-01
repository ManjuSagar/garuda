class TransactionsController < ApplicationController
  before_action :require_admin_login, only: [:index,:show,:update]
  before_action :authenticate_user! 
  
  def new
    @stores = Store.all.map {|s| s.name}
  end

  def show
    trans_id = params[:id]
    @transaction = Transaction.find_by_id(trans_id)
    if(@transaction.nil?)
      render :nothing => true, :status => :not_found
      return
    end
    @vouchers = @transaction.vouchers
    @transaction_items = @transaction.transaction_items
    if(@transaction_items.nil?)
      render :nothing => true, :status => :not_found
      return
    end
    if(@transaction.nil?)
      render :nothing => true, :status => :not_found
      return
    end
  end

  def index
    @transactions = Transaction.all
    respond_to do |format|
      format.html
      format.csv { send_data @transactions.to_csv }
    end
  end

  def update
    file = params[:winner_doc]
    transaction = Transaction.find params[:id]

    if(transaction.nil?)
      flash[:error] = "Transaction with id: #{params[:id]} does not exist"
      redirect_to new_transaction_path
      return
    end

    if(file.nil?)
      flash[:error] = "Select a file before uploading"
      redirect_to transaction_path params[:id]
      return
    end

    if (!transaction.is_winner?)
      flash[:error] = "Upload file for transaction containing winning coupons only."
      redirect_to transaction_path params[:id]
      return
    end
    transaction.winner_doc = file
    transaction.save!
    flash[:notice] = "Transaction updated"
    redirect_to transaction_path transaction.id
  end

  def create

    body = JSON.parse(request.body.read)
    puts "inffffffffffffffffffffffffffff"
    puts body.inspect
    customer_info = body["customerInfo"] 
    receipt_info = body["receiptInfo"]
    voucher_info = body["voucherInfo"]
    voucher_info = voucher_info.nil? ? [] : voucher_info

    total_receipt_value = receipt_info
                          .map{|h| h["amount"].to_i}
                          .inject{|total, val| total+val}

    if(total_receipt_value < 1000)
       render :nothing => true, :status => :bad_request
       return
    end

    errors = []
    valid_vouchers = voucher_info.reject{|info| info["barCode"].blank? }
    customer = Customer.find_by_mobile(customer_info["mobile"])

    if (valid_vouchers.blank?)
      if(!customer.nil? and !customer.is_winner?)
        errors << "No coupons entered! Please enter atleast one coupon to save!"
      end
    else
      duplicate_vouchers = valid_vouchers.group_by {|v| v["barCode"]}.select { |k,v| v.size > 1}.keys
      duplicate_vouchers.each do |v|
        errors << "Duplicate Coupon Codes entered! Coupon No: #{v}"
      end
    end
    if (errors.length > 0)
      render  :json => errors, :status => :bad_request
      return
    end



    customer = Customer.find_by_mobile(customer_info["mobile"])
    

    if(customer.nil?)
      isVoucherPresent = false
      voucher_info.each do |a|
        if a["barCode"].present?
          isVoucherPresent = true
          break
        end
      end

      if(!isVoucherPresent)
        errors << "No coupons entered! Please enter atleast one coupon to save!"
        render :json => errors, :status => :bad_request
        return
      end

      customer = Customer.new(name: customer_info["name"].strip, email: customer_info["email"].strip, mobile: customer_info["mobile"].strip, address: customer_info["address"].strip, occupation: customer_info["occupation"].strip, gender: customer_info["gender"].strip, age: customer_info["age"].strip, remarks: customer_info["remarks"].strip)
    else
      customer.name = customer_info["name"].strip
      customer.email = customer_info["email"].strip
      customer.address = customer_info["address"].strip
      customer.occupation = customer_info["occupation"].strip
      customer.gender = customer_info["gender"].strip
      customer.age = customer_info["age"].strip
      customer.remarks = customer_info["remarks"].strip
    end

    if(customer.is_winner? and !valid_vouchers.empty?)
      render :nothing => true, :status => :bad_request
      return
    end

    if(not customer.is_winner?)
      no_of_vouchers_to_issue = total_receipt_value / 1000

    
      if(valid_vouchers.length > no_of_vouchers_to_issue)
        render :nothing => true, :status => 400
        return
      end
    end

    transaction = customer.transactions.new date: DateTime.now
    transaction.coupon_amount = receipt_info[0]["couponAppliedAmount"]
    receipt_info.each do |receipt|
      store = Store.find_by_name(receipt["storeName"])
      if(store.nil?)
        render :nothing => true, :status => 400
        return
      end
      transaction.transaction_items.new(item_id: receipt["billNo"], store: store, amount: receipt["amount"], is_jwells: receipt["isJwells"], date: Date.today, items_count: receipt["count"])
    end
    
    valid_vouchers.each do |voucher|
      transaction.vouchers.new(barcode_number: voucher["barCode"].strip.upcase)
    end

    begin
      customer.save!      
    rescue ActiveRecord::RecordInvalid => e
      errors = []
      transaction.transaction_items.each do |ti|
        ti.errors.to_a.each do |e|
          if(e == "Item Receipt Taken")
            errors << "Duplicate Purchase, Bill No: #{ti.item_id}"
          end
        end
      end
      
      transaction.vouchers.each do |v|
        v.errors.to_a.each do |e|
          if(e == "Barcode number Voucher Taken")
            errors << "Duplicate Coupon, Coupon Code: #{v.barcode_number}"
          end
        end
      end

      transaction.vouchers.each do |v|
        v.errors.to_a.each do |e|
          if(e == "Voucher master Invalid Voucher")
            errors << "Invalid Coupon, Coupon Code: #{v.barcode_number}"
          end
        end
      end
      
      render  :json => errors, :status => :bad_request
      return
    end

    flash[:notice] = "Transaction saved. Transaction Id = #{transaction.id}"    
    render :nothing => true
  end
end