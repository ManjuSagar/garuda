class ReportsController < ApplicationController
  before_action :require_admin_login

  def index
    @transactions = Transaction.where("date >= ?", Date.today)
    @no_of_transactions = @transactions.length
    # @no_of_coupons = @transactions.map{|t| t.vouchers_length}.inject{|total, vl| total+vl} || 0
    @total_amount = @transactions.map{|t| t.coupon_amount}.inject{|total, vl| total+vl} || 0
  end
end