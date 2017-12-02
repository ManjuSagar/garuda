class Customer < ActiveRecord::Base
   validates :name, :presence => true
   validates :email, :allow_blank => true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}
   validates :mobile, :presence => true, format: {with: /\A^[0-9]{10,10}$\Z/}

   has_many :transactions

   def is_winner?
    t = self.transactions.find {|t| t.is_winner?}
    !t.nil?
   end

   def total_spent
      self.transactions.map{|t| t.total_amount}.inject {|total, t| total + t}
   end

   def all_coupons
    self.transactions.map {|t| t.all_coupons}.join("|")
   end

   def self.to_csv(options = {})
     CSV.generate(options) do |csv|
       columns = column_names + ["total_spent", "coupons"]
       csv <<  columns
       all.each do |c|
          v = c.attributes.values_at(*column_names) + [c.total_spent, c.all_coupons]
         csv << v
       end
     end
   end

   def mark_as_winner
     self.is_winner = true
   end

end