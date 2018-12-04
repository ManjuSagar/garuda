# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Customer.delete_all
Store.delete_all
Transaction.delete_all
TransactionItem.delete_all
VoucherMaster.delete_all
Voucher.delete_all
User.delete_all
VoucherMaster.delete_all
	
User.create!(:email => 'mln@tws.com', :password => 'password', :password_confirmation => 'password', :name => "MLN Krishnan")
User.create!(:email => 'admin@siiplconsulting.com', :password => 'garuda@admin@123', :password_confirmation => 'garuda@admin@123', :name => "Garuda Event Admin", :role => "admin")
User.create!(:email => 'garudaevent@siiplconsulting.com', :password => 'garuda@123', :password_confirmation => 'garuda@123', :name => "Garuda Event")

(1..30).to_a.each {|n| User.create!(:email => "user#{n}@email.com", :password => 'password', :password_confirmation => 'password', :name => "User#{n}")}

current_path = File.dirname(__FILE__)
File.open(current_path+"/2018/stores.csv").each do |line|
  s = Store.new name:line.strip
  s.save!
end

File.open(current_path+"/2018/barcodes.csv").each_with_index do |line, index|
  puts line.strip
  puts index
  VoucherMaster.create! barcode_number: line.strip, serial: '', book: ''
end




# require 'barby/barcode/code_128'
# require 'barby/outputter/png_outputter'


# def generate(c)
#   dir = File.dirname(__FILE__)
#   new_file = File.new("#{dir}/barcodes#{c}.txt", "w")
#   (0...12500).each do |t|
#     puts "#{t}"
#     barcode_text = (0...1).map {(0...2).map { (65 + rand(26)).chr }.join + (0...6).map {(48 + rand(9)).chr}.join}.join
#     code = Barby::Code128.new barcode_text
#     File.open("#{dir}/barcodes/#{barcode_text}.png", 'w'){|f| f.write code.to_png }
#     new_file.puts barcode_text
#   end  
#   new_file.close
# end

# threads = []
# (0...16).each do |t|
#   e = Thread.new { generate(t) }
#   threads << e
# end

# threads.each {|t| t.join}
