require 'test_helper'

class OffersControllerTest < ActionController::TestCase
  fixtures :offers
  
  setup do
    @offer = offers(:offer_one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:offers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create offer" do
    assert_difference('Offer.count') do
      post :create, offer: { description: @offer.description, title: @offer.title }
    end

    assert_redirected_to offer_path(assigns(:offer))
  end
  
  test "should display all the available items with user" do
    
  end
  
  test "should paginate with ten items per page" do
    
  end

  test "should show offer" do
    get :show, id: @offer
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @offer
    assert_response :success
  end

  test "should update offer" do
    put :update, id: @offer, offer: { description: @offer.description, title: @offer.title }
    assert_redirected_to offer_path(assigns(:offer))
  end

  test "should destroy offer" do
    assert_difference('Offer.count', -1) do
      delete :destroy, id: @offer
    end

    assert_redirected_to offers_path
  end
end
