class AddRemarksToCustomer < ActiveRecord::Migration
  def change
    add_column :customers, :remarks, :string, :null => true, :default => ""
  end
end
