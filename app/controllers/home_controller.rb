class HomeController < ApplicationController
  def index
    redirect_to :controller => "transactions", :action => "new"
  end
end
