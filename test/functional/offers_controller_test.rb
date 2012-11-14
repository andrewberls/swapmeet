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

  #TODO
  #test "should paginate with ten items per page"

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

  test "should display rating buttons for bidder if they have not rated the offerer" do
    sign_in users(:two)
    response = responses(:offer_one_to_bid_one)
    response.accept!
    assert_equal false, response.offerer_rated
    get :show, id: offers(:offer_one)
    assert_response :success

    assert_select "div.feedback-container p", { :text => /Leave a rating for\s+#{users(:one).username}:/}
  end

  test "should not display rating buttons for bidder if they have rated the offerer" do
    sign_in users(:two)
    response = responses(:offer_one_to_bid_one)
    response.accept!
    response.update_attributes! :offerer_rated => true
    get :show, id: offers(:offer_one)
    assert_response :success

    assert_select "div.feedback-container p", { :text => /Feedback left/}
  end

  test "should display rating buttons for offerer if they have not rated the bidder" do
    sign_in users(:one)
    response = responses(:offer_one_to_bid_one)
    response.accept!
    assert_equal false, response.bidder_rated
    get :show, id: offers(:offer_one)
    assert_response :success

    assert_select "div.feedback-container p", { :text => /Leave a rating for\s+#{users(:two).username}:/}
  end

  test "should not display the rating buttons the bid has not been accepted" do
    sign_in users(:one)
    response = responses(:offer_one_to_bid_one)
    offer = offers(:offer_one)
    get :show, id: offer
    assert_response :success

    assert_select "div.feedback-container", { :count => 0 }
  end

  test "should display the rating buttons if the bid has been completed" do
    sign_in users(:two)
    response = responses(:offer_one_to_bid_one)
    response.complete!
    response.update_attributes! :bidder_rated => true #unrelated to rest of test just checking that they are not dependent
    assert_equal false, response.offerer_rated
    get :show, id: offers(:offer_one)
    assert_response :success

    assert_select "div.feedback-container p", { :text => /Leave a rating for\s+#{users(:one).username}:/}
  end
  
  test "bidder should be able to leave a rating for offerer" do
    sign_in users(:two)
    response = responses(:offer_one_to_bid_one)
    response.complete!
    assert_equal false, response.offerer_rated
    assert_equal 1, users(:one).up_ratings
    post :rate, offer_id: response.offer.id, bid_id: response.bid.id, rate: 'up'
    
    assert_redirected_to offer_path(response.offer)
    response.reload
    
    assert_equal true, response.offerer_rated
    assert_equal 2, users(:one).reload.up_ratings
  end
  
  test "offerer should be able to leave a rating for offerer" do
    sign_in users(:one) #offerer
    response = responses(:offer_one_to_bid_one)
    response.complete!
    assert_equal 5, users(:two).up_ratings
    assert_equal false, response.bidder_rated
    post :rate, offer_id: response.offer.id, bid_id: response.bid.id, rate: 'up'
    
    assert_redirected_to offer_path(response.offer)
    response.reload

    assert_equal 6, users(:two).reload.up_ratings
    assert_equal true, response.bidder_rated
  end
end
