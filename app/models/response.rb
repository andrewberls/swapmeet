class Response < ActiveRecord::Base
  attr_accessible :offer, :bid, :status

  belongs_to :offer
  belongs_to :bid, class_name: "Offer"

  validates :offer, :presence => true
  validates :bid, :presence => true

  validates_each :offer do |record, attr, value|
    record.errors.add(attr, " cannot receive bids") if not value.can_receive_bids?
  end
end
