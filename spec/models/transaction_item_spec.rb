require "rails_helper"

describe TransactionItem, :type => :model do

  it "should create a TransactionItem" do
    store = Store.new name: 'MAX'
    store.save!

    cust = Customer.new(name: "Chobi", email: "chobi@goo.com", mobile: "9611805469", address: "20, blah, blah", occupation: "Blah", gender: "M", age: 78)
    trans = cust.transactions.new(date: DateTime.now)
  	item = trans.transaction_items.new(item_id: "122ABC", store: store, amount: 1000, date: '2012-03-04')

    cust.save!    

  	all_TransactionItems = TransactionItem.all
  	all_TransactionItems.length.should == 1

  	expected_TransactionItems = all_TransactionItems.first

  	expected_TransactionItems.transact.should == trans
  	expected_TransactionItems.item_id.should == "122ABC"
  	expected_TransactionItems.store.should == store
  	expected_TransactionItems.amount.should == 1000
  	expected_TransactionItems.date.to_s.should	 ==  '2012-03-04'
  end

  it "should be associated with a store always" do
    cust = Customer.new(name: "Chobi", email: "chobi@goo.com", mobile: "9611805469", address: "20, blah, blah", occupation: "Blah", gender: "M", age: 78)
    trans = cust.transactions.new(date: DateTime.now)
  	trans.transaction_items.new item_id: "122ABC", amount: 1000, date: '2012-03-04'

    cust.save

  	all_TransactionItems = TransactionItem.all
  	all_TransactionItems.length.should == 0
  end

  it "should be associated with a transaction always" do
    store = Store.new name: 'MAX'
    store.save!
  	
    expect{
      TransactionItem.create item_id: "122ABC", store: store, amount: 1000, date: '2012-03-04'
    }.to raise_error(ActiveRecord::StatementInvalid)
  	
  end

  it "should ensure presence of amount" do
    Customer.create! id: 1, name: "Chobi", email: "chobi@goo.com", mobile: "9611805469", address: "20, blah, blah", occupation: "Blah", gender: "M", age: 78

  	Transaction.create id: 1, customer_id: 1, date: DateTime.now
  	Store.create id: 1, name: 'MAX'
  	TransactionItem.create transaction_id: 1, item_id: "122ABC", store_id: 1, amount: nil, date: '2012-03-04'

  	all_TransactionItems = TransactionItem.all
  	all_TransactionItems.length.should == 0
  end

  it "should ensure presence of date" do
    Customer.create! id: 1, name: "Chobi", email: "chobi@goo.com", mobile: "9611805469", address: "20, blah, blah", occupation: "Blah", gender: "M", age: 78

  	Transaction.create id: 1, customer_id: 1, date: DateTime.now
  	Store.create id: 1, name: 'MAX'
  	TransactionItem.create transaction_id: 1, item_id: "122ABC", store_id: 1, amount: 2000, date: nil

  	all_TransactionItems = TransactionItem.all
  	all_TransactionItems.length.should == 0
  end

  it "should ensure presence of item_id" do
    Customer.create! id: 1, name: "Chobi", email: "chobi@goo.com", mobile: "9611805469", address: "20, blah, blah", occupation: "Blah", gender: "M", age: 78

  	Transaction.create id: 1, customer_id: 1, date: DateTime.now
  	Store.create id: 1, name: 'MAX'
  	TransactionItem.create transaction_id: 1, item_id: nil, store_id: 1, amount: 2000, date: '2012-03-04'

  	all_TransactionItems = TransactionItem.all
  	all_TransactionItems.length.should == 0
  end

  it "should ensure unique combination of item_id and store_id" do
    Customer.create! id: 1, name: "Chobi", email: "chobi@goo.com", mobile: "9611805469", address: "20, blah, blah", occupation: "Blah", gender: "M", age: 78
  	Transaction.create id: 1, customer_id: 1, date: DateTime.now
  	Store.create id: 1, name: 'MAX'
  	TransactionItem.create! transaction_id: 1, item_id: "122ABC", store_id: 1, amount: 2000, date: '2012-03-04'

    expect{
      TransactionItem.create! transaction_id: 1, item_id: "122ABC", store_id: 1, amount: 2000, date: '2012-03-04'  
    }.to raise_error(ActiveRecord::RecordInvalid, "Validation failed: Item Receipt Taken")
  	


  	all_TransactionItems = TransactionItem.all
  	all_TransactionItems.length.should == 1
  	
  	expected_TransactionItems = all_TransactionItems.first

  	expected_TransactionItems.transaction_id.should == 1
  	expected_TransactionItems.item_id.should == "122ABC"
  	expected_TransactionItems.store_id.should == 1
  	expected_TransactionItems.amount.should == 2000
  	expected_TransactionItems.date.to_s.should	 == '2012-03-04'
  end

  it "should not create a TransactionItem with non existent store_id" do
    Customer.create! id: 1, name: "Chobi", email: "chobi@goo.com", mobile: "9611805469", address: "20, blah, blah", occupation: "Blah", gender: "M", age: 78

  	Transaction.create id: 1, customer_id: 1, date: DateTime.now
  	Store.create id: 1, name: 'MAX'
  	TransactionItem.create transaction_id: 1, item_id: "122pqr", store_id: 2, amount: 2000, date: '2012-03-04'

  	all_TransactionItems = TransactionItem.all
  	all_TransactionItems.length.should == 0
  end

  it "should not create a TransactionItem with invalid date" do
    Customer.create! id: 1, name: "Chobi", email: "chobi@goo.com", mobile: "9611805469", address: "20, blah, blah", occupation: "Blah", gender: "M", age: 78

  	Transaction.create id: 1, customer_id: 1, date: DateTime.now
  	Store.create id: 1, name: 'MAX'
  	TransactionItem.create transaction_id: 1, item_id: "122pqr", store_id: 2, amount: 2000, date: '2012-03-1128'

  	all_TransactionItems = TransactionItem.all
  	all_TransactionItems.length.should == 0
  end

end
