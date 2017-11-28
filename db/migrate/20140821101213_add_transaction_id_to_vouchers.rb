class AddTransactionIdToVouchers < ActiveRecord::Migration
  def change
    add_column :vouchers, :transaction_id, :integer, :null => false
  end
end
