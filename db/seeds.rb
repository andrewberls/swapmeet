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


puts "\nCreating managed seeds.. "

admin_user = User.new(username: "admin", email: "admin@admin.com", password: "password", password_confirmation: "password")
admin_user.save!
good_user  = User.new(username: "gooduser", email: "gooduser@email.com", password: "password", password_confirmation: "password")
good_user.save!

awesome_offer = Offer.new(title: "Awesome offer", description: "I need to get rid of my really awesome stuff.") do |offer|
  offer.user = random_user
end

cool_bid = Offer.new(title: "Cool bid", description: "I will give you really cool stuff for your awesome stuff") do |offer|
  offer.user = good_user
end

awesome_offer.save!
awesome_offer.responses.new(bid: cool_bid) { |resp| resp.status = 'open' }.save!




puts "Done."
puts "Starting random seed generation. Configuration: "
puts "#{mark}user count:  #{USER_COUNT}"
puts "#{mark}offer count: #{OFFER_COUNT}"
puts "#{mark}bid count:   #{BID_COUNT}"
puts ""
beginning_time = Time.now

#--------------------
# Users
#--------------------
USER_COUNT.times do |i|
  User.create!(username: "user#{i}", email: "user#{i}@fake.com", password: "password", password_confirmation: "password")
end



#--------------------
# Offers
#--------------------
OFFER_COUNT.times do |i|
  Offer.new(title: "test-offer#{i}", description: LiterateRandomizer.sentence) do |offer|
    offer.user = random_user
  end.save!
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

  bid = Offer.new(title: "test-bid#{i}", description: LiterateRandomizer.sentence) do |offer|
    offer.user = bid_user
  end
  bid.save!

  response = parent_offer.responses.create(bid: bid)
end


puts "Seed generation completed: #{Time.now - beginning_time}s"
