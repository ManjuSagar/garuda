class TransactionItem < ActiveRecord::Base
	belongs_to :store
	validates :store, :presence => true

	belongs_to :transact, :foreign_key => "transaction_id", class_name: "Transaction"

	validates :amount, :date, :item_id, :presence => true

  validates_uniqueness_of :item_id, :scope => :store_id, :message => "Receipt Taken"

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      binding.pry
      columns = ["id"] + ["transaction_id"] + ["bill_no"] + ["store_name"]+ ["items count"]+ ["amount"]  + ["Jwells"]
      csv <<  columns
      all.each do |c|
         v = [c.id] + [c.transaction_id] +[c.item_id] + [c.store.name] + [c.items_count] + [c.amount] + [c.is_jwells]
        csv << v
      end
    end
  end

end