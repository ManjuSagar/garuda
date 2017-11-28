require "rails_helper"

describe Store, :type => :model do

  it "should create new store" do
    Store.create name: "Cookie Jar"

    all_stores = Store.all 
    all_stores.length.should == 1
    all_stores.first.name.should =="Cookie Jar" 
  end

  it "should ensure store name is not empty" do
    Store.create name: ""

    all_stores = Store.all 
    all_stores.length.should == 0
  end

  it "should ensure store name is unique" do
    Store.create name: "Foo"
    
    expect {
      Store.create! name: "Foo"
    }.to raise_error(ActiveRecord::RecordInvalid)

    all_stores = Store.all 
    all_stores.length.should == 1
  end

end
