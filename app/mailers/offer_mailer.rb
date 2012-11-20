class OfferMailer < ActionMailer::Base
  default from: "profiteers@cs290b.com"

  def bid_received_email(offer)
    @offer = offer
    mail(:to => offer.user.email, :subject => "Bid Received")
  end

  def bid_accepted_email(bid)
    @bid = bid
    mail(:to => bid.user.email, :subject => "Bid Accepted")
  end
end
