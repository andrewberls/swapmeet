class User < ActiveRecord::Base
  attr_accessible :username, :email
  has_many :offers
end
