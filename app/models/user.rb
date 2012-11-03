class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

   # Virtual attribute for authenticating by either username or email
  attr_accessor :login
  

  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, 
    :up_ratings, :down_ratings

  validates :username, :uniqueness => true
  validates :email, :uniqueness => true

  has_many :offers
  
  def initialize(*params) 
    super(*params) #must be called because of Devise
    up_ratings = 0 
    down_ratings = 0
  end
  
  # Provided code to enable login with username or email
  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end
  
  def add_bad_rating
    puts "Method: add_bad_rating"
    puts "up_ratings = #{up_ratings}, #{@up_ratings}"
    puts "down_ratings = #{down_ratings}, #{@down_ratings}"
    puts "email = #{email}, #{@email}"
    puts "login = #{login}"
    puts "self = #{self.inspect}"
    down_ratings += 1
  end
  
  def add_good_rating
    puts "Method: add_good_rating"
    puts "up ratings = #{up_ratings}"
    up_ratings += 1
  end
  
end
