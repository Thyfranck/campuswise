class Notify
  def self.borrower_about_payment_received(record) #payment
    if record.status == Payment::STATUS[:paid]
      Notification.email_after_payment(record).deliver
      @dashboard_notification = DashboardNotification.new(
        :user_id => record.exchange.user.id,
        :exchange_id => record.exchange.id,
        :content => "Payment for the book titled #{record.exchange.book.title} has been received with thankfully.")
      @dashboard_notification.save
      @to = record.exchange.user.phone
      @body = "Payment for the book titled \"#{record.exchange.book.title.truncate(30)}\" has been received thakfully. It will be borrowed in a short time.-Campuswise"
      TwilioRequest.send_sms(@body, @to)
    end
  end

  def self.owner_about_new_request(record) #exchange
    @request_sender = record.user
    @request_receiver = record.book.user
    @requested_book = record.book
    @dashboard_notification =  DashboardNotification.new(
      :user_id => @request_receiver.id,
      :exchange_id => record.id,
      :content => "#{@request_sender.name} wants to borrow your book \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" from \"#{record.starting_date.to_date} to #{record.package == "semester" ? "full semester" : record.ending_date.to_date}\" ")
    @dashboard_notification.save
    Notification.notify_book_owner(record)
    @to = @request_receiver.phone
    @body = "#{@request_sender.name} wants to borrow \"#{@requested_book.title.truncate(25)}\"from #{record.starting_date.to_date} to #{record.package == "semester" ? "full semester" : record.ending_date.to_date},to accept reply 'ACCEPT #{record.id}',to ignore reply 'REJECT #{record.id}'-Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.owner_after_exchange_complete(record) #payment
    @exchange = record.exchange
    @requested_book = record.exchange.book
    @request_receiver = @requested_book.user
    @dashboard_notification = DashboardNotification.new(
      :user_id => @request_receiver.id,
      :exchange_id => @exchange.id,
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
    @dashboard_notification = DashboardNotification.new(
      :user_id => @request_sender.id,
      :exchange_id => @exchange.id,
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
    @dashboard_notification = DashboardNotification.new(
      :user_id => record.user.id,
      :exchange_id => record.id,
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

    @dashboard_notification = DashboardNotification.new(
      :user_id => @request_sender.id,
      :exchange_id => record.id,
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
    
    @dashboard_notification = DashboardNotification.new(
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
end