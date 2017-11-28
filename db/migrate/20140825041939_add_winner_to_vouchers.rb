class AddWinnerToVouchers < ActiveRecord::Migration
  def change
    add_column :vouchers, :winner, :boolean
    add_column :vouchers, :win_date, :date
    add_index :vouchers, :win_date, :unique => true
  end
end
