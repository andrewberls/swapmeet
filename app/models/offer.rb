class Offer < ActiveRecord::Base

  attr_accessible :title, :description

  validates :title,
    presence: true,
    length: { maximum: 50 }

  validates :description, presence: true

  belongs_to :user
  has_many :responses
  has_many :bids, through: :responses

  def can_receive_bids?
    Response.find_by_bid_id(self.id).blank?
  end
  
  scope :offers, joins("LEFT OUTER JOIN responses ON offers.id = responses.bid_id").where("responses.bid_id IS NULL")

end
