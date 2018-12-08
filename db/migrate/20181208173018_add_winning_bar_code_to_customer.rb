class AddWinningBarCodeToCustomer < ActiveRecord::Migration
  def change
  	add_column :customers, :winning_bar_code, :string
  end
end
