class AddRoleToUser < ActiveRecord::Migration
  def change
    add_column :users, :role, :string, :null => false, :default => "operator"
  end
end
