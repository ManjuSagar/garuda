class AddWinningDateForCustomers < ActiveRecord::Migration
  def change
  	add_column :customers, :winning_date, :datetime
  end
end
