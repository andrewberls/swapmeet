class Response < ActiveRecord::Base
  attr_accessible :status

  belongs_to :offer
  belongs_to :bid, class_name: "Offer"
end
