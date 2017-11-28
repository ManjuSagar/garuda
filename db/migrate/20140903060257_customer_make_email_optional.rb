class CustomerMakeEmailOptional < ActiveRecord::Migration
  def change
    change_column :customers, :email, :string, :default => "", :null => true
  end
end
