class OffersController < ApplicationController

  before_filter :authenticate_user!

  before_filter :find_offer, only: [:show, :edit, :update, :destroy]
  before_filter :find_parent_offer, only: [:bid]

  # GET /offers/1/bid
  # POST /offers/1/bid
  # Bidding creates a nested offer relationship using an intermediary
  # response object.
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

  # GET /dashboard
  def dashboard

  end

  # POST /offers/1/accept/:bid_id
  def accept
    Response.transaction do
      bid_resp = Response.where(:offer_id => params[:offer_id], :bid_id => params[:bid_id]).first
      raise ActiveRecord::RecordNotFound if bid_resp.nil?

      # Lock out all the other children of this auction, as well as any parent offers
      # in any other auctions.
      @offer = Offer.find(params[:offer_id])
      other_offer_responses = Response.where(:bid_id => params[:bid_id]).all
      bid_resp.accept!
      ((@offer.responses + other_offer_responses) - [bid_resp]).map(&:lock!)
    end

    flash[:success] = 'You have succesfully accepted the bid'
    respond_to do |format|
      format.html { redirect_to @offer }
      format.json { render json: @offer, status: :created, location: @offer }
    end
  end

  # POST /offers/:offer_id/complete/:bid_id
  def complete
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

  # GET /offers/1
  # GET /offers/1.json
  def show
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

  def find_parent_offer
    @parent_offer = Offer.find(params[:id])
    @parent_offer.can_receive_bids? or raise "Cannot bid on this offer"
  end

end
