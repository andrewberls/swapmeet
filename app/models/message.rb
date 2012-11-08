class Message < ActiveRecord::Base

  attr_accessible :timestamp, :read, :content, :sender_id, :recipient_id
  
  belongs_to :sender,   class_name: "User", foreign_key: "sender_id"
  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"
  
  def mark_as_read!
    self.read = true
  end
  
  scope :all_between, lambda { |user1, user2| 
    where("(sender_id = #{user1.id} AND recipient_id = #{user2.id}) OR \
 (sender_id = #{user2.id} AND recipient_id = #{user1.id})") 
    
  }
  
  scope :order_by_recency, order('updated_at desc')
end