class AddTimeStampsToTranscations < ActiveRecord::Migration
   def self.up # Or `def up` in 3.1
    change_table :transactions do |t|
      t.timestamps
    end

    change_table :transaction_items do |t|
      t.timestamps
    end

    change_column :customers, :winning_date, :datetime
    change_column :transactions, :date, :datetime
    change_column :transaction_items, :date, :datetime

  end
  def self.down # Or `def down` in 3.1
    remove_column :transactions, :created_at
    remove_column :transactions, :updated_at
    remove_column :transaction_items, :created_at
    remove_column :transaction_items, :updated_at
  end
end
