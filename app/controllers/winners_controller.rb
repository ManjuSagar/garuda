class WinnersController < ApplicationController
  before_action :require_admin_login

  def new
  end

  def create
    voucher_barcode = params[:voucher]

    v = Voucher.find_by_win_date Date.today
    
    if(!v.nil?)
      flash[:error] = 'Winner has already been selected for today.'
      redirect_to new_transaction_path
      return
    end

    v = Voucher.find_by_barcode_number voucher_barcode 
    
    if(v.nil?)
      flash[:error] = 'Voucher does not exist. Verify and re-enter.'
      redirect_to new_winner_path
      return
    end



    v.mark_as_winner
    v.save!



    flash[:notice] = 'Winner updated succesfully.'
    redirect_to transaction_path v.transact.id
  end
end