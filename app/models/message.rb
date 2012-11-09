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
  
  #A little help from: http://stackoverflow.com/questions/12027160/sql-query-for-most-recent-messages
  scope :unread_message_summary_for_user, lambda { |recipient|
    where(
      "(sender_id, updated_at)
      IN (
        SELECT sender_id as sender_id, MAX(updated_at) as updated_at \
        FROM messages \
        WHERE messages.read = 0 \ 
        GROUP BY sender_id \
      )").order_by_recency
  }
  
  scope :order_by_recency, order('updated_at desc')
end #      