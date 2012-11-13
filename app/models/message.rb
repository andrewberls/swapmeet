class Message < ActiveRecord::Base

  attr_accessible :timestamp, :read, :content, :sender_id, :recipient_id

  belongs_to :sender,    class_name: "User", foreign_key: "sender_id"
  belongs_to :recipient, class_name: "User", foreign_key: "recipient_id"


  validates_presence_of :content
  validate :valid_recipient_and_sender

  def valid_recipient_and_sender
    errors.add(:recipient_id, 'No Recipient exists with that id') if recipient.nil?
    errors.add(:sender_id, 'No Sender exists with that id') if sender.nil?
  end


  def mark_as_read!
    unless self.read
      update_attributes! read: true
    end
  end

  scope :all_between, lambda { |user1, user2|
    where("(sender_id = #{user1.id} AND recipient_id = #{user2.id}) OR \
 (sender_id = #{user2.id} AND recipient_id = #{user1.id})")

  }

  # A little help from: http://stackoverflow.com/questions/12027160/sql-query-for-most-recent-messages
  scope :unread_message_summary_for_user, lambda { |recipient|
    where(
      "(sender_id, recipient_id, updated_at)
      IN (
        SELECT sender_id as sender_id, recipient_id as recipient_id, MAX(updated_at) as updated_at \
        FROM messages \
        WHERE messages.read = 0 AND messages.recipient_id = #{recipient.id} \
        GROUP BY sender_id \
      )").order_by_recency
  }

  scope :message_summary_for_user, lambda { |recipient|
    where(
      "(sender_id, recipient_id, updated_at)
      IN (
        SELECT sender_id as sender_id, recipient_id as recipient_id, MAX(updated_at) as updated_at \
        FROM messages \
        WHERE recipient_id = #{recipient.id} \
        GROUP BY sender_id \
      )").order_by_recency

  }
  
  scope :recipient_is, lambda { |recipient|
    where(:recipient_id => recipient.id)
  }

  scope :order_by_recency, order('updated_at desc')
end
