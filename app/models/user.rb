class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

   # Virtual attribute for authenticating by either username or email
  attr_accessor :login


  attr_accessible :username, :email, :password, :password_confirmation, :remember_me

  validates :username, :uniqueness => true
  validates :email, :uniqueness => true

  has_many :offers

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
    self.down_ratings += 1
  end

  def add_good_rating
    self.up_ratings += 1
  end

end
