class ExchangeObserver < ActiveRecord::Observer
  observe :exchange, :book, :payment

  def after_save(record)
    if record.class == Payment
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
  end

  def before_create(record)
    if record.class == Exchange
      return false if Book.find(record.book_id).available == false
      return false if Book.find(record.book_id).user.id == User.find(record.user_id).id
      return false if record.user.billing_setting.blank? #check if the user has credit card information
    end
  end
  
  def after_create(record)
    if record.class == Exchange
      @request_sender = record.user
      @request_receiver = record.book.user
      @requested_book = record.book
      @dashboard_notification =  DashboardNotification.new(
        :user_id => @request_receiver.id,
        :exchange_id => record.id,
        :content => "#{@request_sender.name} wants to borrow your book \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" from \"#{record.starting_date.to_date} to #{record.package == "semister" ? "full semister" : record.ending_date.to_date}\" ")
      if @dashboard_notification.save
        Notification.notify_book_owner(record).deliver
        @to = @request_receiver.phone
        @body = "#{@request_sender.name} wants to borrow \"#{@requested_book.title.truncate(30)}\" from #{record.starting_date.to_date} to #{record.package == "semister" ? "full semister" : record.ending_date.to_date},to accept reply YES#{record.id},to ignore reply NO#{record.id} -Campuswise"
        TwilioRequest.send_sms(@body, @to)
      end
    end
  end

  def before_update(record)
    if record.class == Exchange      
      if record.payment.status == Payment::STATUS[:paid]
        return true
      else
        return false
      end
    end
  end

  def after_update(record)
    if record.class == Payment
      if record.status == Payment::STATUS[:paid]
        @exchange = record.exchange
        @request_sender = @exchange.user
        @requested_book = @exchange.book
        @request_receiver = @requested_book.user
        if @requested_book.available == true
          @exchange.update_attribute(:accepted, true)
          @requested_book.update_attribute(:available, false)
          notify_borrower_after_complete(record, @exchange,@request_sender,@requested_book)
          notify_owner_after_complete(record, @exchange,@request_receiver,@requested_book)
          record.exchange.destroy_other_pending_requests
        end
      elsif record.status == Payment::STATUS[:failed]
        record.exchange.destroy
      end
    end
  end

  def notify_owner_after_complete(record, exchange,request_receiver,requested_book)
    @dashboard_notification = DashboardNotification.new(
      :user_id => request_receiver.id,
      :exchange_id => exchange.id,
      :content => "Congratulation,the book titled \"<a href='/books/#{requested_book.id}' target='_blank'> #{requested_book.title.truncate(25)} </a> \" exchanged successfully. Checkout your lended book <a href='/borrow_requests' target='_blank'>list</a>"
    )
    @dashboard_notification.save
    Notification.notify_book_owner_exchange_successfull(record).deliver
    @to = request_receiver.phone
    @body = "Congratulation,the book titled: \"#{requested_book.title.truncate(30)}\" has been lended successfully. -Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def notify_borrower_after_complete(record, exchange,request_sender,requested_book )
    @dashboard_notification = DashboardNotification.new(
      :user_id => request_sender.id,
      :exchange_id => exchange.id,
      :content => "Congratulation, you have successfully borrowed the book titled \"<a href='/books/#{requested_book.id}' target='_blank'> #{requested_book.title.truncate(25)} </a> \" You can see this books owner's contact information in your borrowed book <a href='/borrow_requests' target='_blank'>list</a>"
    )
    @dashboard_notification.save
    Notification.notify_book_borrower_exchange_successfull(record).deliver
    @to = request_sender.phone
    @body = "Congratulation, you have successfully borrowed the book titled: \"#{requested_book.title.truncate(30)}\". -Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def before_destroy(record)  
    if record.class == Book
      return false if record.lended == true
      @exchanges = Exchange.where(:book_id => record.id)
      @notification = DashboardNotification.where(:exchange_id => @exchanges)
      @notification.each {|d| d.destroy}
      @exchanges.each {|d| d.destroy}
    end

    if record.class == Exchange
      @request_sender = record.user
      @request_receiver = record.book.user
      @requested_book = record.book
      if record.payment.blank? and record.declined.present?
        Notification.notify_book_borrower_failed_to_charge(record).deliver
        @dashboard_notification = DashboardNotification.new(
          :user_id => record.user.id,
          :exchange_id => record.id,
          :content => "Borrow request for the book titled : \"#{record.book.title}\" failed due to \"#{record.declined}\"")
        @dashboard_notification.save
        @to = record.user.phone
        @body = "Request for the book titled:\"#{record.book.title.truncate(30)}\" failed due to \"#{record.declined}\" -Campuswise"
        TwilioRequest.send_sms(@body, @to)
      elsif record.payment.blank?
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
        
      elsif record.payment.status == Payment::STATUS[:failed]
        if Book.find(record.book_id).available == true
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
    end
  end
end
