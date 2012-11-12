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
  User.find(rand(1..User.count))
end

def random_offer
  Offer.find(rand(1..Offer.count))
end

mark = " -> "


print "\nCreating managed seeds..."

admin_user = User.new(username: "admin", email: "admin@admin.com", password: "password", password_confirmation: "password")
admin_user.save!
good_user  = User.new(username: "gooduser", email: "gooduser@email.com", password: "password", password_confirmation: "password", up_ratings: 14)
good_user.save!
bad_user   = User.new(username: "baduser", email: "baduser@email.com", password: "password", password_confirmation: "password", down_ratings: 49)
bad_user.save!

awesome_offer = Offer.new(title: "Awesome offer", description: "I need to get rid of my really awesome stuff.") do |offer|
  offer.user = admin_user
end

good_bid = Offer.new(title: "Good bid", description: "I will give you really cool stuff for your awesome stuff") do |offer|
  offer.user = good_user
end

bad_bid = Offer.new(title: "Bad bid", description: "I will probably rip you off or back out") do |offer|
  offer.user = bad_user
end



awesome_offer.save!
awesome_offer.responses.new(bid: good_bid) { |resp| resp.status = 'open' }.save!
awesome_offer.responses.new(bid: bad_bid) { |resp| resp.status = 'open' }.save!




print "Done.\n"
puts "Starting random seed generation. Configuration: "
puts "#{mark}User count:  #{USER_COUNT}"
puts "#{mark}Offer count: #{OFFER_COUNT}"
puts "#{mark}Bid count:   #{BID_COUNT}"
puts ""
beginning_time = Time.now

#--------------------
# Users
#--------------------
print "Creating users..."
USER_COUNT.times do |i|
  User.create!(username: "user#{i}", email: "user#{i}@fake.com", password: "password", password_confirmation: "password")
end
print "Done.\n"



#--------------------
# Offers
#--------------------
print "Creating offers..."
OFFER_COUNT.times do |i|
  Offer.new(title: "test-offer#{i}", description: LiterateRandomizer.sentence) do |offer|
    offer.user = random_user
  end.save!
end
print "Done.\n"


#--------------------
# Responses
#--------------------
# Extra bit of shuffling to ensure only parent offers receive bids,
# and users dont bid on their own offers
print "Creating bids..."

BID_COUNT.times do |i|
  parent_offer = random_offer
  while !parent_offer.is_parent_offer?
    parent_offer = random_offer
  end

  parent_user  = random_user
  bid_user = begin
    user = random_user
    while user == parent_user
      user = random_user
    end

    user
  end

  bid = bid_user.offers.build(title: "test-bid#{i}", description: LiterateRandomizer.sentence)
  response = parent_offer.responses.new(bid: bid) do |resp|
    resp.status = 'open'
  end.save!
  bid.save!
end
print "Done.\n"

puts "Seed generation completed: #{Time.now - beginning_time}s"
