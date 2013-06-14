class Notify
  def self.borrower_about_payment_received(record) #payment
    if record.status == Payment::STATUS[:paid]
      Notification.email_after_payment(record).deliver
      @exchange = record.exchange
      @dashboard = @exchange.dashboard_notifications.new(
        :user_id => record.exchange.user.id,
        :content => "Payment for the book titled #{record.exchange.book.title} has been received with thankfully.")
      @dashboard.save
      @to = record.exchange.user.phone
      @body = "Payment for the book titled \"#{record.exchange.book.title.truncate(30)}\" has been received thakfully. It will be #{record.exchange.package == "buy" ? "sold": "borrowed"} in a short time.-Campuswise"
      TwilioRequest.send_sms(@body, @to)
    end
  end

  def self.borrower_proposal_accept(record) #exchange
    Notification.notify_book_borrower_accept(record).deliver
    @dashboard = record.dashboard_notifications.new(
      :user_id => record.user.id,
      :content => "#{record.package == "buy" ? "Purchase":"Borrow"} request for the book titled : '#{record.book.title}' has been accepted by the #{record.package == "buy" ? "seller":"lender"}. It will be #{record.package == "buy" ? "sold" : "borrowed"} to you as soon as the payment is received and we will notify you.")
    @dashboard.save
    @to = record.user.phone
    @body = "#{record.package == "buy" ? "Purchase":"Borrow"} request for the book titled:'#{record.book.title.truncate(30)}' has been accepted by the #{record.package == "buy" ? "seller":"lender"}.It will be processed when payment is complete -Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.owner_about_new_request(record) #exchange
    @request_sender = record.user
    @request_receiver = record.book.user
    @requested_book = record.book
    if record.package == "buy"
      if record.counter_offer.present?
        @dashboard = record.dashboard_notifications.new(
          :user_id => @request_receiver.id,
          :content => "You wanted to sell the book titled <a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)}</a> at the price of $#{record.amount.to_f} but someone wants to purchase this book at the price of $#{record.counter_offer.to_f}.")
        @dashboard.save
      else
        @dashboard = record.dashboard_notifications.new(
          :user_id => @request_receiver.id,
          :content => "Someone wants to purchase the book titled '<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)}</a>'.")
        @dashboard.save
      end     
    else
      @dashboard = record.dashboard_notifications.new(
        :user_id => @request_receiver.id,
        :content => "Someone wants to borrow your book titled \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" from \"#{record.starting_date.to_date} to #{record.package == "semester" ? "full semester" : ("to next" + " " + record.duration.to_s + " " + record.package).pluralize(record.duration)} (till #{record.ending_date.to_date})\" at the price $#{record.counter_offer.present? ? record.counter_offer.to_f : record.amount.to_f}.")
      @dashboard.save
    end
    Notification.notify_book_owner(record).deliver
    @to = @request_receiver.phone
    if record.counter_offer.present?
      if record.package == 'buy'
        @body = "Someone wants to buy '#{@requested_book.title.truncate(20)}' at the price $#{record.counter_offer.to_f} to negotiate goto our site -Campuswise"
      else
        @body = "Someone wants to borrow '#{@requested_book.title.truncate(20)}' at the price $#{record.counter_offer.to_f} from #{record.starting_date.to_date} to #{record.package == "semester" ? "full semester" : record.ending_date.to_date},to negotiate goto our site -Campuswise"
      end     
    else
      if record.package == 'buy'
        @body = "Someone wants to buy '#{@requested_book.title.truncate(20)}'at the price $#{record.amount.to_f},to accept reply 'ACCEPT #{record.id}',to ignore reply 'REJECT #{record.id}' -Campuswise -Campuswise"
      else
        @body = "Someone wants to borrow '#{@requested_book.title.truncate(20)}' from #{record.starting_date.to_date} to #{record.package == "semester" ? "full semester" : record.ending_date.to_date},at the price $#{record.amount.to_f},to accept reply 'ACCEPT #{record.id}',to ignore reply 'REJECT #{record.id}' -Campuswise"
      end   
    end
    TwilioRequest.send_sms(@body, @to)
  end

  def self.owner_after_exchange_complete(record) #payment
    @exchange = record.exchange
    @requested_book = record.exchange.book
    @request_receiver = @requested_book.user
    @dashboard = @exchange.dashboard_notifications.new(
      :user_id => @request_receiver.id,
      :content => "Congratulation,the book titled \"<a href='/books/#{@requested_book.id}' target='_blank'> #{@requested_book.title.truncate(25)} </a> \" #{record.exchange.package == "buy" ? "sold": "borrowed"} successfully,at the price $#{record.amount.to_f}.#{record.exchange.package == "buy" ? "": "Please inform us at admin@campuswise.com when the book is returned."}"
    )
    @dashboard.save
    Notification.notify_book_owner_exchange_successfull(record).deliver
    @to = @request_receiver.phone
    @body = "Congratulation,the book titled: \"#{@requested_book.title.truncate(30)}\" has been #{record.exchange.package == "buy" ? "sold": "borrowed"} successfully. -Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.borrower_after_exchange_complete(record) #payment
    @exchange = record.exchange
    @requested_book = record.exchange.book
    @request_sender = @exchange.user
    @dashboard = @exchange.dashboard_notifications.new(
      :user_id => @request_sender.id,
      :content => "Congratulation, you have successfully #{record.exchange.package == "buy" ? "puchased":"borrowed"} the book titled <a href='/books/#{@requested_book.id}' target='_blank'> #{@requested_book.title.truncate(25)}</a>. You can see this books #{record.exchange.package == "buy" ? "seller's":"lender's"} contact information in your #{record.exchange.package == "buy" ? "sold": "borrowed"} books <a href='/borrow_requests' target='_blank'>list</a>"
    )
    @dashboard.save
    Notification.notify_book_borrower_exchange_successfull(record).deliver
    @to = @request_sender.phone
    @body = "Congratulation, you have successfully #{record.exchange.package == "buy" ? "puchased": "borrowed"} the book titled: \"#{@requested_book.title.truncate(30)}\". -Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.borrower_about_card_rejected(record) #exchange
    Notification.notify_book_borrower_failed_to_charge(record).deliver
    @dashboard = record.dashboard_notifications.new(
      :user_id => record.user.id,
      :content => "#{record.package == "buy" ? "Puchased":"Borrow"} request for the book titled : \"#{record.book.title}\" failed due to \"#{record.declined}\"")
    @dashboard.save
    @to = record.user.phone
    @body = "#{record.package == "buy" ? "Puchased":"Borrow"} request for the book titled:\"#{record.book.title.truncate(30)}\" failed due to \"#{record.declined}\" -Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.borrower_about_rejected_by_owner(record) #exchange
    @request_sender = record.user
    @requested_book = record.book
    @request_receiver = @requested_book.user
    @dashboard = record.dashboard_notifications.new(
      :user_id => @request_sender.id,
      :content => "Sorry #{record.package == "buy" ? "puchase":"borrow"} request for the book titled : \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" was rejected by the #{record.package == "buy" ? "seller":"borrower"}. Please try other sometime."
    )
    @dashboard.save
    Notification.notify_book_borrower_reject_by_user(record).deliver
    @to = @request_sender.phone
    @body = "Sorry #{record.package == "buy" ? "puchased":"borrow"} request for the book titled:\"#{@requested_book.title.truncate(50)}\" was rejected by the #{record.package == "buy" ? "seller":"borrower"} -Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.borrower_about_card_problem(record) #exchange
    @request_sender = record.user
    @requested_book = record.book
    @request_receiver = @requested_book.user  
    @dashboard = record.dashboard_notifications.new(
      :user_id => @request_sender.id,
      :exchange_id => record.id,
      :content => "Sorry #{record.package == "buy" ? "puchase":"borrow"} request for the book titled : \"<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)} </a> \" was rejected due to your card problem."
    )
    @dashboard.save
    Notification.notify_book_borrower_reject_for_payment(record).deliver
    @to = @request_sender.phone
    @body = "Sorry #{record.package == "buy" ? "puchase":"borrow"} request for the book titled:\"#{@requested_book.title.truncate(50)}\" was rejected due to your card problem.-Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.user_for_withdraw(record) #withdraw_request
    @dashboard = record.dashboard_notifications.new(
      :user_id => record.user.id,
      :content => "Your withdraw request for amount $#{record.amount.to_f} is complete."
    )
    @dashboard.save
    Notification.notify_user_for_withdraw(record).deliver
    @to = record.user.phone
    @body = "Congratulation your withdraw request for amount $#{record.amount.to_f} is complete."
    TwilioRequest.send_sms(@body, @to)
  end

  def self.borrower_about_owner_doesnt_want_to_negotiate(record, requested_price) #exchange
    @dashboard = record.dashboard_notifications.new(
      :user_id => record.user.id,
      :content => "You wanted to #{record.package == 'buy' ? 'purchase' : 'borrow'} the book titled '#{record.book.title}' at the price $#{requested_price}. But #{record.package == 'buy' ? 'seller' : 'lender'} of the book doesn't want to #{record.package == 'buy' ? 'sell' : 'lend'} below the price $#{record.amount.to_f}."
    )
    @dashboard.save
    Notification.borrower_about_owner_doesnt_want_to_negotiate(record, requested_price).deliver
    @to = record.user.phone
    @body = "Lender of the book titled '#{record.book.title.truncate(30)}' doesn't want to negotiate below $#{record.amount.to_f}.Login to our site to accept or reject.- Campuswise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.borrower_about_owner_want_to_negotiate(record) #exchange
    @dashboard = record.dashboard_notifications.new(
      :user_id => record.user.id,
      :content => "You wanted to #{record.package == 'buy' ? 'purchase' : 'borrow'} the book titled '#{record.book.title}' at the price of $#{record.counter_offer.to_f}. But the #{record.package == 'buy' ? 'seller' : 'lender'} wants #{record.package == 'buy' ? 'sell' : 'lend'} the book at price $#{record.amount.to_f}."
    )
    @dashboard.save
    Notification.borrower_about_owner_want_to_negotiate(record).deliver
    @to = record.user.phone
    @body = "Lender of the book titled '#{record.book.title.truncate(30)}' wants to #{record.package == 'buy' ? 'sell' : 'lend'} the book at price $#{record.amount.to_f}.To negotiate goto our site."
    TwilioRequest.send_sms(@body, @to)
  end

  def self.owner_about_negotiation_failed(record) #exchange
    @dashboard = record.dashboard_notifications.new(
      :user_id => record.book.user.id,
      :content => "#{record.package == 'buy' ? 'Buyer' : 'Borrower'} of the book titled '#{record.book.title}' rejected your desired price $#{record.amount.to_f} and cancelled the borrow request."
    )
    @dashboard.save
    Notification.owner_about_negotiation_failed(record).deliver
    @to = record.book.user.phone
    @body = "#{record.package == 'buy' ? 'Buyer' : 'Borrower'} of the book titled '#{record.book.title.truncate(30)}' cancelled the request."
    TwilioRequest.send_sms(@body, @to)
  end

  def self.owner_about_borrower_want_to_negotiate(record) #exchange
    @dashboard = record.dashboard_notifications.new(
      :user_id => record.book.user.id,
      :content => "You wanted to #{record.package == 'buy' ? 'sell' : 'lend'} the book titled '#{record.book.title}' at the price of $#{record.amount.to_f}.But the #{record.package == 'buy' ? 'buyer' : 'borrower'} wants to #{record.package == 'buy' ? 'purchase' : 'borrow'} the book at the price $#{record.counter_offer.to_f}."
    )
    @dashboard.save
    Notification.owner_about_borrower_want_to_negotiate(record).deliver
    @to = record.book.user.phone
    @body = "#{record.package == 'buy' ? 'Buyer' : 'Borrower'}  the book titled '#{record.book.title.truncate(30)}' wants to #{record.package == 'buy' ? 'purchase' : 'borrow'} the book at the price $#{record.counter_offer.to_f}."
    TwilioRequest.send_sms(@body, @to)
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