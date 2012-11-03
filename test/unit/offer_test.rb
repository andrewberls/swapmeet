require 'test_helper'

class OfferTest < ActiveSupport::TestCase

  test "offers should be able to have many bids" do
    offer = offers(:offer_one)
    assert_equal 2, offer.bids.count
  end

  test "namedscope parent_offers should return only offers" do
    offers = Offer.parent_offers
    assert_equal false, offers.include?(offers(:bid_one))
    assert offers.include?(offers(:offer_one))
  end
  
  
end
