class AddTimeStampsToTranscations < ActiveRecord::Migration
   def self.up # Or `def up` in 3.1
    change_table :transactions do |t|
      t.timestamps
    end
  end
  def self.down # Or `def down` in 3.1
    remove_column :transactions, :created_at
    remove_column :transactions, :updated_at
  end
end
