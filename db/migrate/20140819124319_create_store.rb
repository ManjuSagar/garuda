class CreateStore < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.string :name, :null => false
    end
    add_index :stores, :name, :unique => true
  end
end
