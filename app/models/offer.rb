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

  def can_receive_bids?
    Response.find_by_bid_id(self.id).blank?
  end

  # We show only the original public offers ("I want to get rid of my couch") on the home page,
  # not the stuff that is posted in response
  scope :parent_offers, joins("LEFT OUTER JOIN responses ON offers.id = responses.bid_id").where("responses.bid_id IS NULL")

end
