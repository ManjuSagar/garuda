class AddGotSilverToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :got_silver, :boolean, default: false
  end
end
