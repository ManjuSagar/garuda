class CreateTransaction < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.datetime :date, :null => false
      t.integer :customer_id
    end
  end
end
