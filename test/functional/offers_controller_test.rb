require 'test_helper'

class OffersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  fixtures :offers
  
  setup do
    @offer = offers(:offer_one)
    @user = users(:one)
  end

  test "should get index" do
    sign_in @user
    get :index
    assert_response :success
    assert_not_nil assigns(:offers)
  end

  test "should get new" do
    sign_in @user
    get :new
    assert_response :success
  end

  test "should create offer" do
    sign_in @user
    assert_difference('Offer.count') do
      post :create, offer: { description: @offer.description, title: @offer.title }
    end

    assert_redirected_to offer_path(assigns(:offer))
  end
  
  test "open offers" do
    sign_in @user
    get :index
    assert_response :success
    
    
  end
  
  test "should paginate with ten items per page" do
    sign_in @user
    
  end

  test "should show offer" do
    sign_in @user
    get :show, id: @offer
    assert_response :success
  end

  test "should get edit" do
    sign_in @user
    get :edit, id: @offer
    assert_response :success
  end

  test "should update offer" do
    sign_in @user
    put :update, id: @offer, offer: { description: @offer.description, title: @offer.title }
    assert_redirected_to offer_path(assigns(:offer))
  end

  test "should destroy offer" do
    sign_in @user
    assert_difference('Offer.count', -1) do
      delete :destroy, id: @offer
    end

    assert_redirected_to offers_path
  end
end
