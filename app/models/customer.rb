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

   def self.silver_eligble_customers_for_the_day
     d1 = Date.today.to_s + " 00:00:00"
     d2 = Date.today.to_s + " 23:59:59"
     #Customer.joins(:transactions).where("transactions.date >= ? AND transactions.date <= ? and transactions.coupon_amount >= 3000", d1, d2)
     sql = "select customers.id, customers.name, customers.mobile, customers.got_silver, transactions.coupon_amount, transactions.total_sum from customers INNER JOIN transactions ON  customers.id = transactions.customer_id WHERE transactions.date >= '"+ d1 +"' and transactions.date <= '" + d2 +"' and transactions.total_sum >= 3000;"
     res = ActiveRecord::Base.connection.execute(sql)
     res  
   end

   def self.get_top_customers(limit)
      current_time = Time.now
      # one_hour_less_time = current_time
      starting_of_time = current_time.utc.strftime("%Y-%m-%d %H:00:00")
      end_of_time = current_time.utc.strftime("%Y-%m-%d %H:%M:%S") 
      sql = "select c.id, c.name, c.mobile, c.got_silver, SUM(t.coupon_amount), SUM(t.total_sum) as total_amount from customers c INNER JOIN transactions t ON c.id = t.customer_id AND t.created_at BETWEEN '"+ starting_of_time +"' AND '" + end_of_time + "' GROUP BY C.iD ORDER BY sum DESC limit " + limit.to_s + ";"
      ActiveRecord::Base.connection.execute(sql) 
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

   def mark_as_winner(date, voucher)
     self.winning_date = date 
     # self.winning_bar_code = voucher
     self.is_winner = true
   end

  def self.customer_column_names
    columns = column_names
  end

end
