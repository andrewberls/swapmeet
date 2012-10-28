class User < ActiveRecord::Base
  attr_accessible :username, :email
  has_many :offers

  validates :username, :uniqueness => true
  validates :email, :uniqueness => true
end
