require "rails_helper"

describe CustomersController do
  before(:each) do
    user =  User.new(:email => 'mln@tws.com', :password => 'password', :password_confirmation => 'password', :name => "MLN Krishnan")
    user.save!
    sign_in user
  end


  it "Creates a transaction with one receipt" do
    Customer.create! name: "Chobi", email: "chobi@goo.com", mobile: "9611805469", address: "20, blah, blah", occupation: "Blah", gender: "M", age: 78

    get :show,:format => :json, id: "9611805469" 

    expect(response).to have_http_status(:ok)

    body = JSON.parse(response.body)

    body["name"].should == "Chobi"
    body["email"].should == "chobi@goo.com"
    body["mobile"].should == "9611805469"
    body["address"].should == "20, blah, blah"
    body["occupation"].should == "Blah"
    body["age"].should == 78
    body["gender"].should == "M"
  end

  it "should return not found when customer doesnt exist" do
    get :show,:format => :json, id: "9611805469" 

    expect(response).to redirect_to customers_path
  end
end