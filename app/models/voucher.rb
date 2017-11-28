class Voucher < ActiveRecord::Base
	validates :barcode_number, :presence => true

  belongs_to :transact, :foreign_key => "transaction_id", class_name: "Transaction"
  belongs_to :voucher_master, :foreign_key => "barcode_number"
  validates :voucher_master, :presence => { :message => "Invalid Voucher" }

  validates_uniqueness_of :barcode_number, :message => "Voucher Taken"

  def mark_as_winner
    self.winner = true
    self.win_date = Date.today
  end

  def is_winner?
    self.winner
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv <<  column_names + ["Serial Number", "Book Number"]
      all.each do |c|
         v = [c.id] + [c.barcode_number] + [c.transaction_id] + [c.winner] + [c.win_date] + [c.voucher_master.serial] + [c.voucher_master.book]
        csv << v
      end
    end
  end

end
