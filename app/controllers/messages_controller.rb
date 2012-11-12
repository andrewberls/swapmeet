class MessagesController < ApplicationController
  before_filter :authenticate_user!


  def create
    msg = params[:message]
    @message = Message.new(recipient_id: msg[:recipient_id], sender_id: current_user.id, content: msg[:content] )

    respond_to do |format|
      if @message.save
        format.html { redirect_to inbox_messages_path, notice: 'Message sent.' }
        format.json { render json: inbox_messages_path, status: :created, location: inbox_messages_path }
      else
        format.html { redirect_to inbox_messages_path, notice: 'Error: Unable to send.' }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    user      = User.find(params[:id])
    @messages = Message.all_between(current_user, user)

    # TODO: this marks a message as read for both users even if the sender re-views the message
    @messages.map(&:mark_as_read!)

    # New message at bottom
    @message = Message.new(:recipient_id => params[:id])
    if @message.recipient.nil?
      flash[:error] = 'Invalid recipient.'
      redirect_to messages_path
    else
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @message }
      end
    end


  end

  def inbox
    @messages = current_user.unread_messages

    respond_to do |format|
      format.html # inbox.html.erb
      format.json { render json: @messages }
    end
  end

  def index
    @messages = Message.message_summary_for_user(current_user)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @messages }
    end
  end

end
