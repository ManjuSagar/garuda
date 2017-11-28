class AddNumberOfItemsToTransactionItem < ActiveRecord::Migration
  def change
    add_column :transaction_items, :items_count, :integer
    add_column :transaction_items, :item_wise_amount, :string
  end
end
