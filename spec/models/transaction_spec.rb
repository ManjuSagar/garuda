require "rails_helper"

describe Transaction, :type => :model do

  it "should create a transaction" do
    cust = Customer.new(name: "Chobi", email: "chobi@goo.com", mobile: "9611805469", address: "20, blah, blah", occupation: "Blah", gender: "M", age: 78)
    now = DateTime.now
    cust.transactions.new date: now
    cust.save!

    all_transactions = Transaction.all

    all_transactions.length.should == 1
    expected_transaction = all_transactions.first
    expected_transaction.customer.should == cust

    expected_transaction.date.utc.day.should  ==  now.utc.day
    expected_transaction.date.utc.month.should  ==  now.utc.month
    expected_transaction.date.utc.year.should ==  now.utc.year
    
  end

  it "should not create a transaction with non existent customer id" do
    Transaction.create date: DateTime.now

    all_transactions = Transaction.all
    all_transactions.length.should == 0
  end

  it "sholud ensure presence of date" do
    cust = Customer.new(name: "Chobi", email: "chobi@goo.com", mobile: "9611805469", address: "20, blah, blah", occupation: "Blah", gender: "M", age: 78)
    cust.save!

    cust.transactions.new date:nil
    cust.save

    all_transactions = Transaction.all
    all_transactions.length.should == 0
  end

end