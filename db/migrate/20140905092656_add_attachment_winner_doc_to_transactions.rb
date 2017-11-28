class AddAttachmentWinnerDocToTransactions < ActiveRecord::Migration
  def self.up
    change_table :transactions do |t|
      t.attachment :winner_doc
    end
  end

  def self.down
    remove_attachment :transactions, :winner_doc
  end
end
