class AddIsWinnerToUsers < ActiveRecord::Migration
  def change
  	add_column :customers, :is_winner, :boolean, :default_value => false
  end
end
