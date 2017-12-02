class WinnersController < ApplicationController
  before_action :require_admin_login

  def new
  end

  def create
    number = params[:voucher]
    puts "vvvvvvvvvvvvvvvvvvvvvvvvvvv #{params.inspect}"
    v = Customer.find_by_mobile number
    puts "vvvvvvvvvvvvvvvvvvvvvvvvvvv #{v}"
    # if(!v.nil?)
    #   flash[:error] = 'Winner has already been selected for today.'
    #   redirect_to new_transaction_path
    #   return
    # end

    # v = Voucher.find_by_barcode_number voucher_barcode
    #
    if(v.nil?)
      flash[:error] = 'Customer does not exist with this number.'
      redirect_to new_winner_path
      return
    end



    v.mark_as_winner
    v.save!



    flash[:notice] = 'Winner updated succesfully.'
    redirect_to new_winner_path #transaction_path v.transact.id
  end
end