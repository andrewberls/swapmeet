module MessagesHelper

  def message_timestamp(time)
    hour_mins = "%I:%M%P"

    if time < 1.day.ago
      time.strftime("%b %-d at #{hour_mins}") # Oct 26 at 10:57pm
    else
      time.strftime(hour_mins) # 10:57pm
    end
  end

end
