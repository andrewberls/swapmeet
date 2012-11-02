class Response < ActiveRecord::Base
  attr_accessible :bid

  belongs_to :offer
  belongs_to :bid, class_name: "Offer"

  validates :offer, :presence => true
  validates :bid, :presence => true

  validates_each :offer do |record, attr, value|
    record.errors.add(attr, " cannot receive bids") if not value.can_receive_bids?
  end

  # Accept a bid
  def accept!
    self.status = 'accepted'    
    self.save
  end

  def complete!
    self.status = 'completed'    
    self.save
  end

  def lock_out!
    self.status = 'locked'    
    self.save
  end

end
