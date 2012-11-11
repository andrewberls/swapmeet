class OffersController < ApplicationController

  before_filter :authenticate_user!
  before_filter :find_offer, only: [:show, :edit, :update, :destroy]
  before_filter :must_own_offer, only: [:edit, :update, :destroy]

  before_filter :find_parent_offer, only: [:bid]
  before_filter :find_responses, only: [:accept, :complete]


  # GET /offers/1/bid
  # POST /offers/1/bid
  def bid
    if request.get?
      @offer = Offer.new
    else
      @offer = current_user.offers.build(params[:offer])

      response = @parent_offer.responses.new(bid: @offer) do |resp|
        resp.status = 'open'
      end.save

      respond_to do |format|
        if @offer.save
          flash[:success] = 'Your bid was successfully registered.'
          format.html { redirect_to @parent_offer }
          format.json { render json: @offer, status: :created, location: @parent_offer }
        else
          format.html { render action: "bid" }
          format.json { render json: { :offer_errors => @offer.errors, :response_errors => @response.errors }, status: :unprocessable_entity }
        end

      end
    end
  end


  # POST /offers/1/accept/:bid_id
  # Mark a bid as accepted, and  lock out all the other children of this auction,
  # as well as any parent offers in any other auctions.
  # All heavy lifting is accomplished in find_responses
  def accept
    Response.transaction do
      @bid_resp.accept!
      @response_queue.map(&:lock!)
    end

    flash[:success] = 'You have succesfully accepted the bid'
    respond_to do |format|
      format.html { redirect_to @offer }
      format.json { render json: @offer, status: :created, location: @offer }
    end
  end


  # POST /offers/:offer_id/complete/:bid_id
  # Mark a bid as completed, and delete all the other children of this auction,
  # as well as any parent offers in any other auctions.
  # All heavy lifting is accomplished in find_responses
  def complete
    Response.transaction do
      @bid_resp.complete!
      @response_queue.map(&:destroy)
    end

    flash[:success] = 'Trade completed.'
    respond_to do |format|
      format.html { redirect_to @offer }
      format.json { render json: @offer, status: :created, location: @offer }
    end
  end


  def rate
    response = Response.response_for(params[:offer_id], params[:bid_id])
    
    unless response.rated
      # TODO: Can we reduce queries here?
      offer      = Offer.find(params[:offer_id])
      offer_user = offer.user
      bid_user   = Offer.find(params[:bid_id]).user
      rated_user = (current_user == offer_user) ? bid_user : offer_user

      case params[:rate]
      when 'up'   then rated_user.add_good_rating
      when 'down' then rated_user.add_bad_rating
      else
        raise "Rating #{params[:rate].inspect} not recognized"
      end

      response.update_attributes! :rated => true # TODO: BOTH USERS CAN VOTE
      rated_user.save!

      flash[:success] = 'Rating completed.'
      respond_to do |format|
        format.html { redirect_to offer }
        format.json { render json: offer, location: offer }
      end
    end
  end


  # GET /offers
  # GET /offers.json
  def index
    # We show only 'parent' offers ("I want to get rid of my couch"),
    # not offers posted as responses
    @offers = Offer.parent_offers.page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @offers }
    end
  end


  # GET /dashboard
  def dashboard
    # TODO: GET USERS TRADES
    @recent_offers = Offer.parent_offers.last(8)
  end

  # GET /offers/1
  # GET /offers/1.json
  def show
    setup_ratings
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @offer }
    end
  end

  # GET /offers/new
  # GET /offers/new.json
  def new
    @offer = Offer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @offer }
    end
  end

  # GET /offers/1/edit
  def edit
  end

  # POST /offers
  # POST /offers.json
  def create
    @offer = current_user.offers.build(params[:offer])

    respond_to do |format|
      if @offer.save
        format.html { redirect_to @offer, notice: 'Offer was successfully created.' }
        format.json { render json: @offer, status: :created, location: @offer }
      else
        format.html { render action: "new" }
        format.json { render json: @offer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /offers/1
  # PUT /offers/1.json
  def update
    respond_to do |format|
      if @offer.update_attributes(params[:offer])
        format.html { redirect_to @offer, notice: 'Offer was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @offer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /offers/1
  # DELETE /offers/1.json
  def destroy
    @offer.destroy

    respond_to do |format|
      format.html { redirect_to offers_url }
      format.json { head :no_content }
    end
  end

  private

  def find_offer
    # TODO: access checks (is the current user allowed to view/destroy an offer, etc)
    @offer = Offer.find(params[:id])
  end

  def must_own_offer
    reject_unauthorized(current_user == @offer.user, offers_path)
  end

  def find_parent_offer
    @parent_offer = Offer.find(params[:id])
    @parent_offer.can_receive_bids? or raise "Cannot bid on this offer"
  end

  # TODO: This name is horrible. It's intent is to DRY up the responses queries
  # in the accept and complete actions
  #? Perhaps move some of this to the model?
  def find_responses
    @bid_resp = Response.where(offer_id: params[:offer_id], bid_id: params[:bid_id]).first
    @bid_resp.present? or raise ActiveRecord::RecordNotFound
    @offer    = Offer.find(params[:offer_id])

    @parent_responses = Response.where(bid_id: params[:bid_id]).all
    @response_queue   = (@offer.responses + @parent_responses) - [@bid_resp]
  end
  
  def setup_ratings
    @selected_bid = @offer.completed_or_accepted_bid
    @rating_state =
      if @selected_bid.nil?
        :none
      elsif current_user == @selected_bid.user
        if Response.response_for(@offer, @selected_bid).offerer_rated
          :rated
        else
          @user_to_rate = @offer.user
          :display_rate_buttons
          
        end
      elsif current_user == @offer.user 
        if Response.response_for(@offer, @selected_bid).bidder_rated
          :rated
        else
          @user_to_rate = @selected_bid.user
          :display_rate_buttons
        end
      end
  end

end
