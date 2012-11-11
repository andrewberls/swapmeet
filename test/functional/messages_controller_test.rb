require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  # test "the truth" do
  #   assert true
  # end
  
  setup do
    @user = users(:one)
  end

  test "should get index" do
    sign_in @user
    get :inbox
    assert_response :success

  end
  
  test "should get new" do
    sign_in @user
    get :new
    assert_response :success
  end

  test "should create message" do
    sign_in @user
    assert_difference('Message.count') do
      post :create, message: { recipient: users(:two), content: "blah blah blah" }
    end

    assert_redirected_to message_inbox_path(assigns(:offer))
  end
  
  test "index should display all messages" do
    sign_in @user
    get :inbox
    assert_response :success

  end
end
