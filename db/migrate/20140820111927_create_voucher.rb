class CreateVoucher < ActiveRecord::Migration
  def change
    create_table :vouchers do |t|
    	t.string :barcode_number, :null => false
    end
    add_index :vouchers, :barcode_number, :unique => true
  end
end
