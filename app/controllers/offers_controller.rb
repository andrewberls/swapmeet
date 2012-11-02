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
      # @offer = Offer.new(params[:offer]) { |o| o.user = User.first }
      response = @parent_offer.responses.create(bid: @offer)

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

  # POST /offers/1/accept
  def accept
    Response.transaction do
      bid_resp = Response.where(:offer_id => params[:offer_id], :bid_id => params[:bid_id]).first
      parent_offer = Offer.find_by_id(params[:offer_id])
      raise ActiveRecord::RecordNotFound if bid_resp.nil?
      bid_resp.accept!
      (parent_offer.responses - [bid_resp]).each { |r| r.lock_out! }
    end
  end

  # POST /offers/1/complete/3
  def complete
  end

  # GET /offers
  # GET /offers.json
  def index
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
