require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @user = users(:one)
  end

  test "should get index" do
    sign_in @user
    get :inbox
    assert_response :success

  end

  test "should create message" do
    sign_in @user
    assert_difference('Message.count') do
      post :create, message: { recipient_id: users(:two).id, content: "blah blah blah" }
      assert_redirected_to inbox_messages_path
      assert_equal "Message sent.", flash[:notice]
    end

  end

  test "inbox should display all unread messages" do
    sign_in @user
    get :inbox
    assert_response :success

  end
  
  test "should only mark messages as read if user is the sender" do
    sign_in @user
    get :show, :id => users(:two).id
    assert_response :success
    
    assert_equal true, messages(:two).read
    assert_equal false, messages(:one).read
    assert_equal false, messages(:three).read
    
    
  end
end
