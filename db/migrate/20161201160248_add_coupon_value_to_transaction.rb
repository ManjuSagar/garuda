class AddCouponValueToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :coupon_amount, :integer, :null => false
  end
end
