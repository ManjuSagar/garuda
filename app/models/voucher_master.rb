class VoucherMaster < ActiveRecord::Base
  validates :barcode_number, :presence => true
  validates_uniqueness_of :barcode_number
  self.primary_key = :barcode_number
end
