class OfferMailer < ActionMailer::Base
  default from: "profiteers@cs290b.com"

  def welcome_email(user)
    @user = user
    @url  = "http://example.com/login"
    mail(:to => user.email, :subject => "Welcome to My Awesome Site")
  end
end
