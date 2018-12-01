class AddTotalSumToTransactions < ActiveRecord::Migration
  def change
  	 add_column :transactions, :total_sum, :integer
  	 change_table :vouchers do |t|
  		t.timestamps
  	 end
  end
end
