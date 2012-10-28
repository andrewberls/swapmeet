class Offer < ActiveRecord::Base
  attr_accessible :title, :description

  belongs_to :user
  has_many :responses
  has_many :bids, through: :responses

  after_initialize :init
  def init
    # Allows Offer objects to be constructed with just the data
    # For now, all offers belong to the first user in the DB 
    # FIXME: properly associate the Offer with the user logged in
    self.user = User.first!
  end
end
