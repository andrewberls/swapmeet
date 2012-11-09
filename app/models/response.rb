class Response < ActiveRecord::Base

  VALID_STATES = %w( open accepted locked completed )

  attr_accessible :offer, :bid, :status, :offerer_rated, :bidder_rated

  belongs_to :offer
  belongs_to :bid, class_name: "Offer"

  validates :offer, :presence => true
  validates :bid, :presence => true

  validates_inclusion_of :status, :in => VALID_STATES, :message => "Status is not valid"

  validates_each :offer do |record, attr, value|
    record.errors.add(attr, " cannot receive bids") if not value.can_receive_bids?
  end

  # Accept a bid
  def accept!
    update_attributes! status: 'accepted'
  end

  # Complete a transaction - i.e., goods have been physically exchanged
  def complete!
    update_attributes! status: 'completed'
  end

  # Lock out a response - i.e., when a different response on the same offer
  # has been accepted
  def lock!
    update_attributes! status: 'locked'
  end

end
