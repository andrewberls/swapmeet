class Offer < ActiveRecord::Base

  attr_accessible :title, :description, :image, :tag_list

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

  acts_as_taggable_on :tags

  # We show only the original public offers ("I want to get rid of my couch") on the home page,
  # not the stuff that is posted in response
  scope :parent_offers, joins("LEFT OUTER JOIN responses ON offers.id = responses.bid_id").where("responses.bid_id IS NULL")

  def self.search(q)
    known_tags = ActsAsTaggableOn::Tag.pluck(:name)
    ret = scoped
    if q
      q.split.each do |w|
        if known_tags.include?(w)
          ret = ret.tagged_with(w)
        else
          ret = ret.where("title LIKE '%#{w}%'")
        end
      end
    end
    ret
  end


  # -----------------
  # PARENT OFFERS
  # -----------------
  def is_parent_offer?
    Response.find_by_bid_id(id).blank?
  end

  # You can only bid on open parent offers
  def can_receive_bids?
    is_parent_offer? && bids.empty?
  end

  # Bid that has been accepted
  def accepted_bid
    accepted_response.present? ? accepted_response.bid : nil
  end

  # Bid that has been completed
  def completed_bid
    completed_response.present? ? completed_response.bid : nil
  end

  def completed_or_accepted_bid
    completed_bid || accepted_bid
  end


  # -----------------
  # BIDS
  # -----------------
  def locked?
    bid_response.status == 'locked'
  end

  def accepted?
    bid_response.status == 'accepted'
  end

  private

  def detect_response(status)
    responses.detect { |r| r.status == status }
  end

  def accepted_response
    detect_response 'accepted'
  end

  def completed_response
    detect_response 'completed'
  end

  def bid_response
    Response.find_by_bid_id(id)
  end

end
