require 'test_helper'

class ResponseTest < ActiveSupport::TestCase
  test "named scope should return the response for an offer and a bid" do
    assert_equal responses(:offer_one_to_bid_one), Response.response_for(offers(:offer_one), offers(:bid_one))
  end
end
