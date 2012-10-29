require 'test_helper'

class OfferTest < ActiveSupport::TestCase

    test "offers should be able to have many bids" do
      offer = offers(:offer_one)
      assert_equal 2, offer.bids.count
    end
end
