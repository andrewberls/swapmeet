#--------------------
# Config options
#--------------------
# Micro: 100, 100, 175     (1.243559s)
# Small: 1000, 1000, 1750  (8.704556s - old 93.520896s)
# Medium: 4500, 5000, 6000 (46.315948s)

USER_COUNT  = 1000
OFFER_COUNT = 1000
BID_COUNT   = 1750


#--------------------
# Utilites
#--------------------
def execute(query)
  ActiveRecord::Base.connection.execute(query)
end

def random_user_id
  rand(1..User.count)
end

def random_offer_id
  rand(1..Offer.count)
end

def random_user
  User.find(random_user_id)
end

def random_offer
  Offer.find(random_offer_id)
end

mark = " -> "



#-------------------------------------------
# MANAGED SEEDS
#-------------------------------------------
print "\nCreating managed seeds..."
managed_start = Time.now

admin_user = User.new(username: "admin", email: "admin@admin.com", password: "password", password_confirmation: "password"); admin_user.save!
good_user  = User.new(username: "gooduser", email: "gooduser@email.com", password: "password", password_confirmation: "password", up_ratings: 14); good_user.save!
bad_user   = User.new(username: "baduser", email: "baduser@email.com", password: "password", password_confirmation: "password", down_ratings: 49); bad_user.save!

awesome_offer = Offer.new(title: "Awesome offer", description: "I need to get rid of my really awesome stuff.") { |o| o.user = admin_user }
good_bid      = Offer.new(title: "Good bid", description: "I will give you really cool stuff for your awesome stuff") { |o| o.user = good_user }
bad_bid       = Offer.new(title: "Bad bid", description: "I will probably rip you off or back out") { |o| o.user = bad_user }

awesome_offer.save!
awesome_offer.responses.new(bid: good_bid) { |resp| resp.status = 'open' }.save!
awesome_offer.responses.new(bid: bad_bid) { |resp| resp.status = 'open' }.save!

print "Done. (#{Time.now - managed_start}s)\n"



#-------------------------------------------
# RANDOM SEEDS
#-------------------------------------------
# Random seed generation with Ruby/Rails methods is very slow,
# so here we enjoy a brief detour into the land of SQL.
puts "Starting random seed generation. Configuration: "
puts "#{mark}User count:  #{USER_COUNT}"
puts "#{mark}Offer count: #{OFFER_COUNT}"
puts "#{mark}Bid count:   #{BID_COUNT}\n\n"

beginning_time = Time.now

#--------------------
# Users
#--------------------
# Password hardcoded to 'password'

print "Creating users..."
user_start = Time.now
USER_COUNT.times do |i|
  query = %Q{INSERT INTO `users` (`created_at`, `current_sign_in_at`, `current_sign_in_ip`, `down_ratings`, `email`, `encrypted_password`, `last_sign_in_at`, `last_sign_in_ip`, `remember_created_at`, `reset_password_sent_at`, `reset_password_token`, `sign_in_count`, `up_ratings`, `updated_at`, `username`) VALUES ('#{Time.now.to_s(:db)}', NULL, NULL, 0, 'user#{i}@fake.com', '$2a$10$pvCaaiZW5O43M/r7xCeKkOJ3Vlgv8pUgvl77C6SFrot4Ml1eBeN1a', NULL, NULL, NULL, NULL, NULL, 0, 0, '#{Time.now.to_s(:db)}', 'user#{i}')}

  execute(query)
end
print "Done. (#{Time.now - user_start}s)\n"



#--------------------
# Offers
#--------------------
offer_start = Time.now
print "Creating offers..."
OFFER_COUNT.times do |i|
  desc    = LiterateRandomizer.sentence
  user_id = random_user_id
  query = %Q{INSERT INTO `offers` (`created_at`, `description`, `image_content_type`, `image_file_name`, `image_file_size`, `image_updated_at`, `title`, `updated_at`, `user_id`) VALUES ('#{Time.now.to_s(:db)}', "#{desc}", NULL, NULL, NULL, NULL, 'test-offer#{i}', '#{Time.now.to_s(:db)}', #{user_id})}

  execute(query)
end
print "Done. (#{Time.now - offer_start}s)\n"



#--------------------
# Responses
#--------------------
# Extra bit of shuffling to ensure only parent offers receive bids,
# and users dont bid on their own offers
print "Creating bids..."

bid_start = Time.now
BID_COUNT.times do |i|

  parent_offer_id = random_offer_id
  parent_user_id   = Offer.find(parent_offer_id).user.id
  bid_user_id = begin
    id = random_user_id
    while id == parent_user_id
      id = random_user_id
    end
    id
  end

  desc      = LiterateRandomizer.sentence
  bid_query = %Q{INSERT INTO `offers` (`created_at`, `description`, `image_content_type`, `image_file_name`, `image_file_size`, `image_updated_at`, `title`, `updated_at`, `user_id`) VALUES ('#{Time.now.to_s(:db)}', "#{desc}", NULL, NULL, NULL, NULL, 'test-bid#{i}', '#{Time.now.to_s(:db)}', #{bid_user_id})}
  execute(bid_query)

  bid_id = Offer.last.id # TODO
  resp_query = %Q{INSERT INTO `responses` (`bid_id`, `bidder_rated`, `created_at`, `offer_id`, `offerer_rated`, `status`, `updated_at`) VALUES (#{bid_id}, 0, '#{Time.now.to_s(:db)}', #{parent_offer_id}, 0, 'open', '#{Time.now.to_s(:db)}')}
  execute(resp_query)

end
print "Done. (#{Time.now - bid_start}s)\n"


puts "Seed generation completed: #{Time.now - beginning_time}s"
