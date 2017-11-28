class CreateTransactionItem < ActiveRecord::Migration
  def change
    create_table :transaction_items do |t|
    	t.integer  :transaction_id, :null => false
    	t.string   :item_id, :null => false
    	t.integer  :store_id, :null => false
    	t.integer  :amount, :null => false
    	t.date     :date, :null => false
        t.boolean  :is_jwells, :null => true
    end
    add_index :transaction_items, [:item_id, :store_id], :unique => true
  end
end
