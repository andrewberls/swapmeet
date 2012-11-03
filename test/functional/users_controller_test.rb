require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup do
    @input_attributes = { 
      username: "donv",
      email: "donv@gmail.com",
      password: "elsecreto",
      password_confirmation:  "elsecreto"
    }
    @user = users(:one)
    @admin_user = users(:admin)  # For now, same as any other user
  end

  test "should get index" do
    sign_in @admin_user
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: @input_attributes
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    sign_in @user
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    sign_in @user
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    sign_in @user
    put :update, id: @user, user: { email: @user.email, username: @user.username }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    sign_in @admin_user
    assert_difference('User.count', -1) do
      delete :destroy, id: @user
    end

    assert_redirected_to users_path
  end
end
