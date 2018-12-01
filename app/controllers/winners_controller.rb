class WinnersController < ApplicationController
  before_action :require_admin_login

  def new
  end

  def create
    number = params[:number]
    date = params[:date]
    customer = nil
    already_winned_customer = Customer.find_by_winning_date date
    puts "vvvvvvvvvvvvvvvvvvvvvvvvvvv #{already_winned_customer}"

    if(already_winned_customer)
       flash[:error] = 'Already one Customer has won this date,'
      redirect_to new_winner_path
      return
    end

    voucher = Voucher.find_by_barcode_number number 

    if (voucher)
      customer_id = voucher.transact.customer_id
      customer = Customer.find customer_id
    else 
      flash[:error] = 'Not a valid voucher.'
      redirect_to new_winner_path
    end  

    #customer = Customer.find_by_mobile number

    # if(!v.nil?)
    #   flash[:error] = 'Winner has already been selected for today.'
    #   redirect_to new_transaction_path
    #   return
    # end

    # v = Voucher.find_by_barcode_number voucher_barcode
    #
    if(customer.nil?)
      flash[:error] = 'Customer does not exist with this number.'
      redirect_to new_winner_path
      return
    end

    if(!customer.nil? && customer.winning_date != nil && customer.is_winner)
      flash[:error] = 'This Customer has already won.'
      redirect_to new_winner_path
      return
    end



    customer.mark_as_winner(date)
    customer.save!



    flash[:notice] = 'Winner updated succesfully.'
    redirect_to new_winner_path #transaction_path v.transact.id
  end
end