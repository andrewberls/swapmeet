#--------------------
# SCHEMA
#--------------------
# table "users"
#   string   "username"
#   string   "email"
#
# table "offers"
#   string   "title"
#   text     "description"
#   integer  "user_id"
#
# table "responses"
#   integer  "offer_id"
#   integer  "bid_id"
#   string   "status"



# lr = LiterateRandomizer.create
# puts lr.sentence
# puts lr.paragraph




#--------------------
# Users
#--------------------
User.create(username: "admin", email: "admin@admin.com", password: "password", password_confirmation: "password")

# 10.times do |i|
#   User.create(username: "user{i}", email: "user#{i}@fake.com")
# end



#--------------------
# Offers
#--------------------
# 2.times do |i|
#   Offer.create(title: "test", description: "test").tap { |o| o.user = RANDOM_USER }
# end




#--------------------
# Responses
#--------------------
