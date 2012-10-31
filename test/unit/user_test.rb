require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  setup do
    @user = User.create!( { :email => "user@test.com", :password =>  "test123"} )
  end
  
  test "a new User should have zero up ratings and zero down ratings" do
    assert_equal 0, @user.up_ratings
    assert_equal 0, @user.down_ratings
  end
  
  test "a good rating should up good karma count by one" do
    @user.add_good_rating
    assert_equal 1, @user.up_ratings
    assert_equal 0, @user.down_ratings
  end
  
  test "a bad rating should up bad karma count by one" do   
    @user = users(:two) or raise "Could not find user"
    puts "user = #{@user.inspect}"
    @user.add_bad_rating
    assert_equal 6, @user.up_ratings
    assert_equal 1, @user.down_ratings
  end
end
