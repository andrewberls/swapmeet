class Response < ActiveRecord::Base
  attr_accessible :offer, :bid, :status

  belongs_to :offer
  belongs_to :bid, class_name: "Offer"
end
