class Store < ActiveRecord::Base
  validates :name, :presence => true

  has_many :transaction_items

  validates_uniqueness_of :name
end