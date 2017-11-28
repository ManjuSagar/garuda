namespace :db_seed do
	task :build => :environment do
	  current_path = File.dirname(__FILE__)
      
      file = File.open(current_path+"/barcodes1.csv")
      file.each do |line|
	      attrs = line.strip.split("\t")
	      p = VoucherMaster.find_by_barcode_number(attrs[0])
	      p.serial = attrs[1]
	      p.book = attrs[2]
	      p.save!
      end
	end
end
 
