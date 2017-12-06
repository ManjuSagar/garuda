class Customer < ActiveRecord::Base
   validates :name, :presence => true
   validates :email, :allow_blank => true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}
   validates :mobile, :presence => true, format: {with: /\A^[0-9]{10,10}$\Z/}

   has_many :transactions

   def is_winner?
    t = self.transactions.find {|t| t.is_winner?}
    !t.nil?
   end

   def total_spent(date)
     d1 = date.to_s + " 00:00:00"
     d2 = date.to_s + " 23:59:59"
     self.transactions.where("date >= ? AND date <= ?", d1, d2).map{|t| t.total_amount}.inject {|total, t| total + t}
   end

   def coupon_amount(date)
     d1 = date.to_s + " 00:00:00"
     d2 = date.to_s + " 23:59:59"
     self.transactions.where("date >= ? AND date <= ?", d1, d2).map{|t| t.coupon_amount}.inject {|total, t| total + t}
   end

   def all_coupons
    self.transactions.map {|t| t.all_coupons}.join("|")
   end

   def total_spent_by_customer
     self.transactions.map{|t| t.total_amount}.inject {|total, t| total + t}
   end

   def self.to_csv(options = {})
     CSV.generate(options) do |csv|
       columns = column_names + ["total_spent", "coupons"]
       csv <<  columns
       all.each do |c|
          v = c.attributes.values_at(*column_names) + [c.total_spent_by_customer, c.all_coupons]
         csv << v
       end
     end
   end

   def mark_as_winner
     self.is_winner = true
   end

  def self.customer_column_names
    columns = column_names
  end

end
