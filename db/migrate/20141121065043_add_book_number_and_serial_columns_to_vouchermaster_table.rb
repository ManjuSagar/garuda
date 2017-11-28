class AddBookNumberAndSerialColumnsToVouchermasterTable < ActiveRecord::Migration
  def change
    add_column :voucher_masters, :serial, :string
    add_column :voucher_masters, :book, :string
  end
end
