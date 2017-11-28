class CreateCustomer < ActiveRecord::Migration
  def change

    create_table :customers do |t|
      t.string   :name, :null => false
      t.string   :mobile
      t.string   :email, :null => false
      t.string   :address
      t.string   :occupation
      t.string   :gender
      t.integer  :age
    end

    add_index :customers, :mobile, :unique => true
  end
end
