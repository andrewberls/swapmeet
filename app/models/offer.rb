class Offer < ActiveRecord::Base

  attr_accessible :title, :description

  validates :title,
    presence: true,
    length: { maximum: 50 }

  validates :description, presence: true

  belongs_to :user
  has_many :responses
  has_many :bids, through: :responses

  # Can you make a bid on this offer?
  # i.e., you can't bid on bids
  def can_receive_bids?
    Response.find_by_bid_id(self.id).blank?
  end

  # We show only the original public offers ("I want to get rid of my couch") on the home page,
  # not the stuff that is posted in response
  scope :parent_offers, joins("LEFT OUTER JOIN responses ON offers.id = responses.bid_id").where("responses.bid_id IS NULL")

  # The bid that the parent offer has accepted
  def accepted_bid
    accepted_response.present? ? accepted_response.bid : nil
  end

  private

  def accepted_response
    responses.detect { |r| r.status == 'accepted' }
  end

end
