class MessagesController < ApplicationController
  before_filter :authenticate_user!

  
  def create
    @message = Message.new(recipient_id: params[:message][:recipient_id], sender_id: current_user.id, content: params[:message][:content] )
    
    respond_to do |format|
      if @message.save
        format.html { redirect_to messages_inbox_path, notice: 'Message sent.' }
        format.json { render json: messages_inbox_path, status: :created, location: messages_inbox_path }
      else
        format.html { redirect_to messages_inbox_path, notice: 'Error: Unable to send.' }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def show
    #raise "params = #{params.inspect}"
    user = User.find(params[:id])
    @messages = Message.all_between(current_user, user)
    @messages.each { |m| m.mark_as_read! }
    
    #new message at bottom
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
    @messages = Message.unread_message_summary_for_user(current_user)
    
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
