class OffersController < ApplicationController

  #############################################################################################
  #
  # Bidding on public offers
  #
  # Bidding basically creates a new Offer object using a slightly different codepath
  # that keeps track of the parent offer and also generates the Response object.
  #
  # We reuse the same templates as much as we can, so we want to keep the "@offer"
  # name for the new object being created.

  def new_bid_on
    @parent_offer = Offer.find_by_id!(params[:offer_id])
    @parent_offer.can_receive_bids? or raise "Cannot bid on this offer"
    @offer = Offer.new
  end

  def create_bid_on
    @parent_offer = Offer.find_by_id!(params[:offer_id])
    @parent_offer.can_receive_bids? or raise "Cannot bid on this offer"

    @offer = Offer.new(params[:offer])
    @response = Response.new(:offer => @parent_offer, :bid => @offer)

    respond_to do |format|
      if @offer.save and @response.save
        format.html { redirect_to @parent_offer, notice: 'Your bid was successfully registered.' }
        format.json { render json: @offer, status: :created, location: @parent_offer }
      else
        format.html { render action: "new_bid_on" }
        format.json { render json: { :offer_errors => @offer.errors, :response_errors => @response.errors }, status: :unprocessable_entity }
      end
    end
  end


  #############################################################################################
  #
  # Almost-standard scaffolding for the public offers
  #

  # GET /offers
  # GET /offers.json
  def index
    # We show only the original public offers ("I want to get rid of my couch"),
    # not the stuff that is posted in response
    # TODO: Is there a cleaner way to do this with the current models? yes, use NamedScopes
    @offers = Offer.joins("LEFT OUTER JOIN responses ON offers.id = responses.bid_id").where("responses.bid_id IS NULL").page(params[:page]).per(10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @offers }
    end
  end

  # GET /offers/1
  # GET /offers/1.json
  def show
    @offer = Offer.find(params[:id])

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
    @offer = Offer.find(params[:id])
  end

  # POST /offers
  # POST /offers.json
  def create
    @offer = Offer.new(params[:offer])

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
    @offer = Offer.find(params[:id])

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
    @offer = Offer.find(params[:id])
    @offer.destroy

    respond_to do |format|
      format.html { redirect_to offers_url }
      format.json { head :no_content }
    end
  end
end
