class User < ActiveRecord::Base
  attr_accessible :username, :email, :password, :password_confirmation
  has_many :offers
  has_secure_password

  validates :username, :uniqueness => true
  validates :email, :uniqueness => true
end
