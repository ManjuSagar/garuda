class Transaction < ActiveRecord::Base
	belongs_to :customer
	validates :customer, :presence => true

	validates :date, :presence => true

  has_many :transaction_items
  has_many :vouchers

  has_attached_file :winner_doc
  validates_attachment :winner_doc, content_type: { content_type: "application/pdf" }

  def total_amount
    self.transaction_items.map{|ti| ti.amount}.inject {|total, t| total + t}
  end

  def has_winner_doc?
    !self.winner_doc.blank?
  end

  def is_winner?
    v = self.vouchers.find {|v| v.is_winner?}
    !v.nil?
  end

  def all_coupons
    self.vouchers.map {|v| v.barcode_number}
  end

  def vouchers_length
    self.vouchers.size
  end

  def customer_name
    self.customer.name
  end

  def mobile_number
    self.customer.mobile
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      columns = ["id"] + ["date"] + ["customer_id"] + ["customer name"] + ["Mobile Number"]+ ["total"] + ["coupon Value Amount"]
      csv <<  columns
      all.each do |c|
         v = [c.id] + [c.date.localtime.strftime("%Y-%m-%d %H:%M:%S")] +[c.customer_id] + [c.customer_name] + [c.mobile_number] + [c.total_amount] + [c.coupon_amount]
        csv << v
      end
    end
  end

end