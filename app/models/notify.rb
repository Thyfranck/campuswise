class Notify
  def self.borrower_about_payment_received(record) #payment
    if record.status == Payment::STATUS[:paid]
      Notification.email_after_payment(record).deliver
      @exchange = record.exchange
      @dashboard_notification = @exchange.dashboard_notifications.new(
        :user_id => record.exchange.user.id,
        :content => "Payment for the book titled #{record.exchange.book.title} has been received with thankfully.")
      @dashboard_notification.save
      @to = record.exchange.user.phone
      @body = "Payment for the book titled \"#{record.exchange.book.title.truncate(30)}\" has been received thakfully. It will be borrowed in a short time.-Campuswise"
      TwilioRequest.send_sms(@body, @to)
    end
  end

  def self.borrower_proposal_accept(record) #exchange
    Notification.notify_book_borrower_accept(record).deliver
    @dashboard_notification = record.dashboard_notifications.new(
      :user_id => record.user.id,
      :content => "Borrow request for the book titled : \"#{record.book.title}\" has been accepted by the owner. It will be borrowed to you as soon as the payment is received and we will notify you.")
    @dashboard_notification.save
    @to = record.user.phone
    @body = "Request for the book titled:\"#{record.book.title.truncate(30)}\"has been accepted by the owner.It will be processed when payment is complete -Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.owner_about_new_request(record) #exchange
    @request_sender = record.user
    @request_receiver = record.book.user
    @requested_book = record.book
    if record.counter_offer.present? and record.amount.to_f != record.counter_offer.to_f
      if record.package == "buy"
        @dashboard_notification = record.dashboard_notifications.new(
          :user_id => @request_receiver.id,
          :content => "#{@request_sender.name} wants to buy your book \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" from \"#{record.starting_date.to_date} to #{record.package == "semester" ? "full semester" : record.ending_date.to_date}\" ")
        @dashboard_notification.save
      else
        @dashboard_notification = record.dashboard_notifications.new(
          :user_id => @request_receiver.id,
          :content => "#{@request_sender.name} wants to borrow your book \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" from \"#{record.starting_date.to_date} to #{record.package == "semester" ? "full semester" : record.ending_date.to_date}\" ")
        @dashboard_notification.save
        Notification.notify_book_owner(record)
        @to = @request_receiver.phone
        @body = "#{@request_sender.name} wants to borrow \"#{@requested_book.title.truncate(25)}\"from #{record.starting_date.to_date} to #{record.package == "semester" ? "full semester" : record.ending_date.to_date},to accept reply 'ACCEPT #{record.id}',to ignore reply 'REJECT #{record.id}'-Campuswise"
        TwilioRequest.send_sms(@body, @to)
      end
    else
      if record.package == "buy"
        @dashboard_notification = record.dashboard_notifications.new(
          :user_id => @request_receiver.id,
          :content => "#{@request_sender.name} wants to buy your book \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" from \"#{record.starting_date.to_date} to #{record.package == "semester" ? "full semester" : record.ending_date.to_date}\" ")
        @dashboard_notification.save
      else
        @dashboard_notification = record.dashboard_notifications.new(
          :user_id => @request_receiver.id,
          :content => "#{@request_sender.name} wants to borrow your book \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" from \"#{record.starting_date.to_date} to #{record.package == "semester" ? "full semester" : record.ending_date.to_date}\" ")
        @dashboard_notification.save
        Notification.notify_book_owner(record)
        @to = @request_receiver.phone
        @body = "#{@request_sender.name} wants to borrow \"#{@requested_book.title.truncate(25)}\"from #{record.starting_date.to_date} to #{record.package == "semester" ? "full semester" : record.ending_date.to_date},to accept reply 'ACCEPT #{record.id}',to ignore reply 'REJECT #{record.id}'-Campuswise"
        TwilioRequest.send_sms(@body, @to)
      end
    end

    
  end

  def self.owner_after_exchange_complete(record) #payment
    @exchange = record.exchange
    @requested_book = record.exchange.book
    @request_receiver = @requested_book.user
    @dashboard_notification = @exchange.dashboard_notifications.new(
      :user_id => @request_receiver.id,
      :content => "Congratulation,the book titled \"<a href='/books/#{@requested_book.id}' target='_blank'> #{@requested_book.title.truncate(25)} </a> \" lended successfully. Please inform us at admin@campuswise.com when the book is returned."
    )
    @dashboard_notification.save
    Notification.notify_book_owner_exchange_successfull(record).deliver
    @to = @request_receiver.phone
    @body = "Congratulation,the book titled: \"#{@requested_book.title.truncate(30)}\" has been lended successfully. -Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.borrower_after_exchange_complete(record) #payment
    @exchange = record.exchange
    @requested_book = record.exchange.book
    @request_sender = @exchange.user
    @dashboard_notification = @exchange.dashboard_notifications.new(
      :user_id => @request_sender.id,
      :content => "Congratulation, you have successfully borrowed the book titled <a href='/books/#{@requested_book.id}' target='_blank'> #{@requested_book.title.truncate(25)}</a>. You can see this books owner's contact information in your borrowed book <a href='/borrow_requests' target='_blank'>list</a>"
    )
    @dashboard_notification.save
    Notification.notify_book_borrower_exchange_successfull(record).deliver
    @to = @request_sender.phone
    @body = "Congratulation, you have successfully borrowed the book titled: \"#{@requested_book.title.truncate(30)}\". -Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.borrower_about_card_rejected(record) #exchange
    Notification.notify_book_borrower_failed_to_charge(record).deliver
    @dashboard_notification = record.dashboard_notifications.new(
      :user_id => record.user.id,
      :content => "Borrow request for the book titled : \"#{record.book.title}\" failed due to \"#{record.declined}\"")
    @dashboard_notification.save
    @to = record.user.phone
    @body = "Request for the book titled:\"#{record.book.title.truncate(30)}\" failed due to \"#{record.declined}\" -Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.borrower_about_rejected_by_owner(record) #exchange
    @request_sender = record.user
    @requested_book = record.book
    @request_receiver = @requested_book.user
    @dashboard_notification = record.dashboard_notifications.new(
      :user_id => @request_sender.id,
      :content => "Sorry borrow request for the book titled : \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" was rejected by the user. Please try other sometime."
    )
    @dashboard_notification.save
    Notification.notify_book_borrower_reject_by_user(record).deliver
    @to = @request_sender.phone
    @body = "Sorry request for the book titled:\"#{@requested_book.title.truncate(50)}\" was rejected by the user -Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.borrower_about_card_problem(record) #exchange
    @request_sender = record.user
    @requested_book = record.book
    @request_receiver = @requested_book.user  
    @dashboard_notification = record.dashboard_notifications.new(
      :user_id => @request_sender.id,
      :exchange_id => record.id,
      :content => "Sorry request for the book titled : \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" was rejected due to your card problem."
    )
    @dashboard_notification.save
    Notification.notify_book_borrower_reject_for_payment(record).deliver
    @to = @request_sender.phone
    @body = "Sorry request for the book titled:\"#{@requested_book.title.truncate(50)}\" was rejected due to your card problem.-Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.user_for_withdraw(record) #withdraw_request
    @dashboard_notification = record.dashboard_notifications.new(
      :user_id => record.user.id,
      :content => "Your withdraw request for amount $#{record.amount} is complete."
    )
    @dashboard_notification.save
    Notification.notify_user_for_withdraw(record).deliver
    @to = record.user.phone
    @body = "Congratulation your withdraw request for amount $#{record.amount} is complete."
    TwilioRequest.send_sms(@body, @to)
  end

  def self.borrower_about_owner_doesnt_want_to_negotiate(record) #exchange
    @dashboard_notification = record.dashboard_notifications.new(
      :user_id => record.user.id,
      :content => "Owner of the book titled '#{record.book.title}' doesn't want to negotiate with your given price #{record.counter_offer}"
    )
    @dashboard_notification.save
#    Notification.notify_user_for_withdraw(record).deliver
#    @to = record.user.phone
#    @body = "Congratulation your withdraw request for amount $#{record.amount} is complete."
#    TwilioRequest.send_sms(@body, @to)
  end

  def self.admin_for_book_returned(record) #exchange
    @admin_notification = record.dashboard_notifications.new(
      :admin_user_id => AdminUser.first.id,
      :content => "User: #{record.book.user.name} with email:#{record.book.user.email} says that he has got return the book \"<a href='/admin/books/#{record.book.id}'>#{record.book.title.truncate(50)}</a> \" "
    )
    @admin_notification.save
  end

  def self.admin_for_book_not_returned(record) #exchange
    @admin_notification = record.dashboard_notifications.new(
      :admin_user_id => AdminUser.first.id,
      :content => "User: #{record.book.user.name}, email:#{record.book.user.email} says that didn't got back the book \"<a href='/admin/books/#{record.book.id}'>#{record.book.title.truncate(50)}</a> \" "
    )
    @admin_notification.save
  end
end