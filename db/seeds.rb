#--------------------
# Config options
#--------------------
USER_COUNT  = 100
OFFER_COUNT = 100
BID_COUNT   = 175


#--------------------
# Utilites
#--------------------
def random_user
  User.all.shuffle.first
end

mark = " -> "


puts "\nStarting seed generation. Configuration: "
puts "#{mark}user count:  #{USER_COUNT}"
puts "#{mark}offer count: #{OFFER_COUNT}"
puts "#{mark}bid count:   #{BID_COUNT}"
puts ""
beginning_time = Time.now

#--------------------
# Users
#--------------------
User.create(username: "admin", email: "admin@admin.com", password: "password", password_confirmation: "password")

USER_COUNT.times do |i|
  User.create!(username: "user#{i}", email: "user#{i}@fake.com", password: "password", password_confirmation: "password")
end



#--------------------
# Offers
#--------------------
OFFER_COUNT.times do |i|
  Offer.create!(title: "test-offer#{i}", description: LiterateRandomizer.sentence).tap do |offer|
    offer.user = random_user
  end
end



#--------------------
# Responses
#--------------------
BID_COUNT.times do |i|
  parent_offer = Offer.all.shuffle.first
  parent_user  = random_user
  bid_user = begin
    user = random_user
    # Since we're choosing random users, make sure a user isn't bidding on its own offer
    while user == parent_user
      puts "#{mark}bid_user was equal to parent_user, shuffling"
      user = random_user
    end
    user
  end

  bid = Offer.create!(title: "test-bid#{i}", description: LiterateRandomizer.sentence).tap do |offer|
    offer.user = bid_user
  end

  response = parent_offer.responses.create(bid: bid)
end


puts "Seed generation completed: #{Time.now - beginning_time}s"
