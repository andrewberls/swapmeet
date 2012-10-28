class Offer < ActiveRecord::Base
  attr_accessible :title, :description

  belongs_to :user
  has_many :responses
  has_many :bids, through: :responses

  def can_receive_bids?
    # See also the offers list controller method
    Response.find_by_bid_id(self.id).nil?
  end

  after_initialize :init
  def init
    # Allows Offer objects to be constructed with just the data
    # For now, all offers belong to the first user in the DB 
    # FIXME: properly associate the Offer with the user logged in
    self.user = User.first!
  end
end
