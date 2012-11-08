class Offer < ActiveRecord::Base

  attr_accessible :title, :description, :image

  has_attached_file :image, :styles => { :thumb => "100x100>" }

  validates :title,
    presence: true,
    length: { maximum: 50 }

  validates :description, presence: true

  # Probably an excess of caution, but why not?
  validates_format_of :image_file_name,
    :with=>/\A(.*)\.(jpeg|jpg|png|gif)\z/i,
    :message=> "File name has to end with a supported extension",
    :on => :update,
    :if => lambda{ |object| object.image.present? }

  validates_attachment :image,
    :content_type => { :content_type => ["image/png", "image/jpeg", "image/gif"] },
    :size => { :in => 0..5.megabytes },
    :if => lambda{ |object| object.image.present? }

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

  def accepted_response
    detect_response 'accepted'
  end

  def completed_response
    detect_response 'completed'
  end

  # The bid that the parent offer has accepted
  def accepted_bid
    accepted_response.present? ? accepted_response.bid : nil
  end

  def completed_bid
    completed_response.present? ? completed_response.bid : nil
  end

  def accepted?
    accepted_bid.present?
  end

  def completed?
    completed_bid.present?
  end

  def sibling_responses_for(bid_resp)
    responses - [bid_resp]
  end

  def parents(options={})
    # options[:except] => Response to exclude
    # return all parent responses (offers this bid is part of)
  end

  private

  def detect_response(status)
    responses.detect { |r| r.status == status }
  end

end
