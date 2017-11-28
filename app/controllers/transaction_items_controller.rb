class TransactionItemsController < ApplicationController
  before_action :require_admin_login

  def index
    @transaction_items = TransactionItem.all
    respond_to do |format|
      format.html
      format.csv { send_data @transaction_items.to_csv }
    end
  end
end