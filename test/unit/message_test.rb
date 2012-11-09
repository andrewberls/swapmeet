require 'test_helper'

class MessageTest < ActiveSupport::TestCase

  test "should be able to create a message" do
    user_one = users(:one)
    user_two = users(:two)
    message = Message.create!(sender_id: user_one.id, recipient_id: user_two.id, content: "This is my test")
    assert message
    assert_equal user_one, message.sender
    assert_equal user_two, message.recipient
    assert_equal "This is my test", message.content
    assert_equal false, message.read
  end
  
  test "should be able to mark message as read" do
    message = Message.create!(sender_id: users(:one).id, recipient_id: users(:two).id, content: "This is my test")
    assert_equal false, message.read
    message.mark_as_read!
    assert_equal true, message.read
  end
  
  test "should be able to get all messages between two users from most recent to least recent" do
    Message.destroy_all
    
    Time.expects(:now).returns(Time.local(2012, 11, 6, 5, 5, 5)).at_least_once
    m1 = Message.create!(sender_id: users(:one).id, recipient_id: users(:two).id, content: "This is my test")
    Time.expects(:now).returns(Time.local(2012, 11, 7, 5, 5, 5)).at_least_once
    m2 = Message.create!(sender_id: users(:two).id, recipient_id: users(:one).id, content: "This is my test")
    Time.expects(:now).returns(Time.local(2012, 11, 8, 5, 5, 5)).at_least_once
    m3 = Message.create!(sender_id: users(:one).id, recipient_id: users(:two).id, content: "This is my test")
    Time.expects(:now).returns(Time.local(2012, 11, 7, 7, 5, 5)).at_least_once
    Message.create!(sender_id: users(:admin).id, recipient_id: users(:two).id, content: "This is my test")  
    
    assert Message.all.size > 3
    message_list = Message.all_between(users(:one), users(:two))
    
    assert_equal 3, message_list.size
    message_list = message_list.order_by_recency
    assert_equal [m3.id, m2.id, m1.id], message_list.map { |m| m.id }  
  end
  
  test "should be able to get a list of the users with its most recent unread message" do
    Message.destroy_all
    
    #two unread from one user
    Time.expects(:now).returns(Time.local(2012, 11, 6, 5, 5, 5)).at_least_once
    m1 = Message.create!(sender_id: users(:two).id, recipient_id: users(:one).id, content: "This is my test")
    Time.expects(:now).returns(Time.local(2012, 11, 7, 5, 5, 5)).at_least_once
    m2 = Message.create!(sender_id: users(:two).id, recipient_id: users(:one).id, content: "This is my test2")
    assert_equal false, m1.read
    assert_equal false, m2.read
    
    #one unread from another user
    m3 = Message.create!(sender_id: users(:admin).id, recipient_id: users(:one).id, content: "This is my test3")  
    assert_equal false, m3.read
    
    #no unread from third user
    user3 = User.create! email: "sarah@test.com", password: 'password'
    m4 = Message.create!(sender_id: user3.id, recipient_id: users(:one).id, content: "This is my test4")  
    m4.update_attributes! :read => true
    
    unread_messages = Message.unread_message_summary_for_user(users(:one))
    assert_equal [m3.id, m2.id], unread_messages.map { |um| um.id }
  end
  
  test "should be able to get a list of the most recent message from each user" do
    
  end
end
