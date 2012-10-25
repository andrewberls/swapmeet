class Offer < ActiveRecord::Base
  attr_accessible :title, :description

  belongs_to :user
  has_many :responses
  has_many :bids, through: :responses
end
