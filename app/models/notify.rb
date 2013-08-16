class Notify

  def self.helpers
    ActionController::Base.helpers
  end

#  def self.borrower_about_payment_received(record) 
#    if record.status == Payment::STATUS[:paid]
#      Notification.email_after_payment(record).deliver
#      @exchange = record.exchange
#      @dashboard = @exchange.dashboard_notifications.new(
#        :user_id => record.exchange.user.id,
#        :content => "Payment for the book titled #{record.exchange.book.title} has been received with thankfully.")
#      @dashboard.save
#      @to = record.exchange.user.phone
#      @body = "Payment for the book titled '#{record.exchange.book.title.truncate(30)}' has been received thakfully. It will be #{record.exchange.package == "buy" ? "sold": "borrowed"} in a short time.-CampusWise"
#      TwilioRequest.send_sms(@body, @to)
#    end
#  end

#  def self.borrower_proposal_accept(record) 
#    Notification.notify_book_borrower_accept(record).deliver
#    @dashboard = record.dashboard_notifications.new(
#      :user_id => record.user.id,
#      :content => "#{record.package == "buy" ? "Purchase":"Borrow"} request for the book titled '#{record.book.title}' has been accepted by the #{record.package == "buy" ? "seller":"lender"}. It will be #{record.package == "buy" ? "sold" : "borrowed"} to you as soon as the payment is received and we will notify you.")
#    @dashboard.save
#    @to = record.user.phone
#    @body = "#{record.package == "buy" ? "Purchase":"Borrow"} request for the book titled'#{record.book.title.truncate(30)}' has been accepted by the #{record.package == "buy" ? "seller":"lender"}.It will be processed when payment is complete -CampusWise"
#    TwilioRequest.send_sms(@body, @to)
#  end

  def self.owner_about_new_request(record) #exchange
    @request_sender = record.user
    @request_receiver = record.book.user
    @requested_book = record.book
    if record.package == "buy"
      if record.counter_offer.present?
        @dashboard = record.dashboard_notifications.new(
          :user_id => @request_receiver.id,
          :content => "Someone wants to buy your book titled '<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)}</a>' for #{Notify.helpers.number_to_currency(record.counter_offer.to_f, :prescision => 2)}.")
        @dashboard.save
      else
        @dashboard = record.dashboard_notifications.new(
          :user_id => @request_receiver.id,
          :content => "Someone wants to buy your book titled '<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)}</a>' for $#{record.book.price.to_f}.")
        @dashboard.save
      end     
    else
      @dashboard = record.dashboard_notifications.new(
        :user_id => @request_receiver.id,
        :content => "Someone wants to borrow your book titled '<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)}</a>' for #{record.counter_offer.present? ? Notify.helpers.number_to_currency(record.counter_offer.to_f, :prescision => 2) : Notify.helpers.number_to_currency(record.amount.to_f, :prescision => 2)} for #{record.package == "semester" ? "semester" : (record.duration.to_s + " " + record.package).pluralize(record.duration)} from #{record.starting_date.to_date} to #{record.ending_date.to_date}.")
      @dashboard.save
    end
    Notification.notify_book_owner(record).deliver
    @to = @request_receiver.phone
    if record.counter_offer.present?
      if record.package == 'buy'
        @body = "Someone wants to buy your book titled '#{@requested_book.title.truncate(20)}' for #{Notify.helpers.number_to_currency(record.counter_offer.to_f, :prescision => 2)} to negotiate goto our site -CampusWise"
      else
        @body = "Someone wants to borrow your book titled '#{@requested_book.title.truncate(20)}' for #{Notify.helpers.number_to_currency(record.counter_offer.to_f, :prescision => 2)} for #{record.package == "semester" ? "semester" : (record.duration.to_s + " " + record.package).pluralize(record.duration)} from #{record.starting_date.to_date} to #{record.ending_date.to_date} -CampusWise"
      end
    else
      if record.package == 'buy'
        @body = "Someone wants to buy your book titled '#{@requested_book.title.truncate(20)}' for #{Notify.helpers.number_to_currency(record.amount.to_f, :prescision => 2)},to accept text 'ACCEPT #{record.id}',to ignore text 'REJECT #{record.id}' -CampusWise"
      else
        @body = "Someone wants to borrow your book titled '#{@requested_book.title.truncate(20)}' for #{Notify.helpers.number_to_currency(record.amount.to_f, :prescision => 2)} for #{record.package == "semester" ? "semester" : (record.duration.to_s + " " + record.package).pluralize(record.duration)} from #{record.starting_date.to_date} to #{record.ending_date.to_date}, to accept text'ACCEPT #{record.id}',to ignore text 'REJECT #{record.id}'-CampusWise"
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
      :content => "Congratulations, you #{record.exchange.package == "buy" ? "sold" : "lent"} the book titled '<a href='/books/#{@requested_book.id}' target='_blank'>#{@requested_book.title.truncate(25)}</a>' successfully."
    )
    @dashboard.save
    Notification.notify_book_owner_exchange_successfull(record).deliver
    @to = @request_receiver.phone
    @body = "Congratulations, you #{record.exchange.package == "buy" ? "sold" : "lent"} the book titled '#{@requested_book.title.truncate(25)}' successfully. -CampusWise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.borrower_after_exchange_complete(record) #payment
    @exchange = record.exchange
    @requested_book = record.exchange.book
    @request_sender = @exchange.user
    @dashboard = @exchange.dashboard_notifications.new(
      :user_id => @request_sender.id,
      :content => "Congratulations, you have successfully #{record.exchange.package == "buy" ? "puchased" : "borrowed"} the book titled '<a href='/books/#{@requested_book.id}' target='_blank'> #{@requested_book.title.truncate(25)}</a>'. You can now view the book owner's contact inforamtion <a href='/borrow_requests' target='_blank'>here</a>"
    )
    @dashboard.save
    Notification.notify_book_borrower_exchange_successfull(record).deliver
    @to = @request_sender.phone
    @body = "Congratulations, you have successfully #{record.exchange.package == "buy" ? "puchased":"borrowed"} the book titled '#{@requested_book.title.truncate(25)}'. -CampusWise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.borrower_about_card_rejected(record) #exchange
    Notification.notify_book_borrower_failed_to_charge(record).deliver
    @dashboard = record.dashboard_notifications.new(
      :user_id => record.user.id,
      :content => "We're sorry your #{record.package == "buy" ? "puchasing":"borrowing"} of the book titled '#{record.book.title}' has been canceled due to #{record.declined}")
    @dashboard.save
    @to = record.user.phone
    @body = "We're sorry your #{record.package == "buy" ? "puchasing":"borrowing"} of the book titled '#{record.book.title.truncate(30)}' has been canceled due to #{record.declined}. -CampusWise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.borrower_about_rejected_by_owner(record) #exchange
    @request_sender = record.user
    @requested_book = record.book
    @request_receiver = @requested_book.user
    @dashboard = record.dashboard_notifications.new(
      :user_id => @request_sender.id,
      :content => "Your request for the book titled'<a href='/books/#{record.book.id}' target='_blank'> #{record.book.title.truncate(25)}</a>' was rejected by its owner. Please try again later."
    )
    @dashboard.save
    Notification.notify_book_borrower_reject_by_user(record).deliver
    @to = @request_sender.phone
    @body = "Your request for the book titled'#{@requested_book.title.truncate(50)}' was rejected by its owner -CampusWise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.borrower_about_card_problem(record) #exchange
    @request_sender = record.user
    @requested_book = record.book
    @request_receiver = @requested_book.user  
    @dashboard = record.dashboard_notifications.new(
      :user_id => @request_sender.id,
      :exchange_id => record.id,
      :content => "Sorry #{record.package == "buy" ? "puchasing" : "borrowing"} of the book titled '<a href='/books/#{record.book.id}' target='_blank'>#{record.book.title.truncate(25)}</a>' has been canceled due to a problem with your card."
    )
    @dashboard.save
    Notification.notify_book_borrower_reject_for_payment(record).deliver
    @to = @request_sender.phone
    @body = "Sorry #{record.package == "buy" ? "puchasing" : "borrowing"} of the book titled '#{@requested_book.title.truncate(50)}' has been canceled due to a problem with your card. -CampusWise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.user_for_withdraw(record) #withdraw_request
    @dashboard = record.dashboard_notifications.new(
      :user_id => record.user.id,
      :content => "Your withdraw request for amount #{Notify.helpers.number_to_currency(record.amount.to_f, :prescision => 2)} is complete."
    )
    @dashboard.save
    Notification.notify_user_for_withdraw(record).deliver
    @to = record.user.phone
    @body = "Your withdraw request for amount #{Notify.helpers.number_to_currency(record.amount.to_f, :prescision => 2)} is complete. -CampusWise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.borrower_about_owner_want_to_negotiate(record) #exchange
    @dashboard = record.dashboard_notifications.new(
      :user_id => record.user.id,
      :content => "The owner of the book titled '#{record.book.title}' that you requested would like to negotiate a price."
    )
    @dashboard.save
    Notification.borrower_about_owner_want_to_negotiate(record).deliver
    @to = record.user.phone
    @body = "The owner of the book titled'#{record.book.title.truncate(30)}' that you requested would like to negotiate a price. To negotaite goto our site. -CampusWise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.owner_about_borrower_want_to_negotiate(record) #exchange
    @dashboard = record.dashboard_notifications.new(
      :user_id => record.book.user.id,
      :content => "The person who requested the book titled '#{record.book.title}' wants to negotiate a price."
    )
    @dashboard.save
    Notification.owner_about_borrower_want_to_negotiate(record).deliver
    @to = record.book.user.phone
    @body = "The person who requested the book titled '#{record.book.title.truncate(30)}' wants to negotiate a price. To negotaite goto our site. -CampusWise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.owner_about_negotiation_failed(record) #exchange
    @dashboard = record.dashboard_notifications.new(
      :user_id => record.book.user.id,
      :content => "The person who requested the book titled '#{record.book.title}' rejected your last negotiation and canceled his or her #{record.package == 'buy' ? 'purchase' : 'borrow'} request."
    )
    @dashboard.save
    Notification.owner_about_negotiation_failed(record).deliver
    @to = record.book.user.phone
    @body = "The person who requested the book titled '#{record.book.title.truncate(30)}' rejected your last negotiation and canceled his or her #{record.package == 'buy' ? 'purchase' : 'borrow'} request. -CampusWise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.borrower_about_owner_doesnt_want_to_negotiate(record, requested_price) #exchange
    @dashboard = record.dashboard_notifications.new(
      :user_id => record.user.id,
      :content => "The owner of the book titled '#{record.book.title}' does not want to negotiate at this time."
    )
    @dashboard.save
    Notification.borrower_about_owner_doesnt_want_to_negotiate(record, requested_price).deliver
    @to = record.user.phone
    @body = "The owner of the book titled '#{record.book.title.truncate(30)}' does not want to negotiate at this time. To accept or reject goto our site.- CampusWise"
    TwilioRequest.send_sms(@body, @to)
  end

  def self.admin_for_book_returned(record) #exchange
    @admin_notification = record.dashboard_notifications.new(
      :admin_user_id => AdminUser.first.id,
      :content => "User: #{record.book.user.name} with email:#{record.book.user.email} says that he has got return the book '<a href='/admin/books/#{record.book.id}'>#{record.book.title.truncate(50)}</a> ' "
    )
    @admin_notification.save
  end

  def self.admin_for_book_not_returned(record) #exchange
    @admin_notification = record.dashboard_notifications.new(
      :admin_user_id => AdminUser.first.id,
      :content => "User: #{record.book.user.name}, email:#{record.book.user.email} says that didn't got back the book '<a href='/admin/books/#{record.book.id}'>#{record.book.title.truncate(50)}</a> ' , <a href='/admin/exchanges/#{record.id}'>Charge The User</a>"
    )
    @admin_notification.save
  end

  def self.book_dropped_off(record) #exchange
    @admin_notification = record.dashboard_notifications.new(
      :admin_user_id => AdminUser.first.id,
      :content => "User: #{record.book.user.name}, email:#{record.book.user.email} says that he/she dropped off the book '<a href='/admin/books/#{record.book.id}'>#{record.book.title.truncate(50)}</a> '"
    )
    @admin_notification.save

    @borrower_notification = record.dashboard_notifications.new(
      :user_id => record.user.id,
      :content => "Owner of the book titled '<a href='/books/#{record.book.id}'>#{record.book.title}</a>' says that gave you the book, please confirm us <a href='/borrow_requests' target='_blank'>here</a>"
    )
    @borrower_notification.save
    Notification.owner_dropped_off_the_book(record).deliver
    @to = record.user.phone
    @body = "Owner of the book titled '#{record.book.title.truncate(30)}' confirms that dropped off the book to you. Please confirm us that you received the book. -CampusWise"
    TwilioRequest.send_sms(@body, @to)
    
    @owner_notification = record.dashboard_notifications.new(
      :user_id => record.book.user.id,
      :content => "You dropped off the book '<a href='/books/#{record.book.id}'>#{record.book.title}</a>' at #{record.dropped_off_at.to_date}."
    )
    @owner_notification.save
  end

  def self.book_received(record)
    @admin_notification = record.dashboard_notifications.new(
      :admin_user_id => AdminUser.first.id,
      :content => "User: #{record.user.name}, email:#{record.user.email} says that he/she received the book '<a href='/admin/books/#{record.book.id}'>#{record.book.title.truncate(50)}</a> '"
    )
    @admin_notification.save
    
    @borrower_notification = record.dashboard_notifications.new(
      :user_id => record.user.id,
      :content => "You received the book '<a href='/books/#{record.book.id}'>#{record.book.title}</a>'."
    )
    @borrower_notification.save

    @owner_notification = record.dashboard_notifications.new(
      :user_id => record.book.user.id,
      :content => "User: #{record.user.name}, email:#{record.user.email} confirmed us that received the book '<a href='/books/#{record.book.id}'>#{record.book.title}</a>' from you."
    )
    @owner_notification.save
    Notification.borrower_received_the_book(record).deliver
    @to = record.book.user.phone
    @body = "#{record.package == 'buy' ? 'Buyer' : 'Borrower'} of the book titled '#{record.book.title.truncate(30)}' confirmed us that received the book from you. -CampusWise"
    TwilioRequest.send_sms(@body, @to)
  end

#  def self.admin_for_book_received(record) 
#    @admin_notification = record.dashboard_notifications.new(
#      :admin_user_id => AdminUser.first.id,
#      :content => "User: #{record.user.name}, email:#{record.user.email} says that he/she received the book '<a href='/admin/books/#{record.book.id}'>#{record.book.title.truncate(50)}</a> '"
#    )
#    @owner_notification = record.dashboard_notifications.new(
#      :user_id => record.book.user.id,
#      :content => "User: #{record.user.name}, email:#{record.user.email} confirmed that, received the book '<a href='/books/#{record.book.id}'>#{record.book.title}</a>'"
#    )
#    @owner_notification.save
#  end

  def self.owner_full_price_charged(record) #exchange
    @dashboard = record.dashboard_notifications.new(
      :user_id => record.book.user.id,
      :content => "The full price of the book titled '<a href='/books/#{record.book.id}'>#{record.book.title}</a>', amount of $#{record.book.price.to_f} is paid to you. Please check your balance"
    )
    @dashboard.save
    Notification.owner_full_price_charged(record).deliver
    @to = record.book.user.phone
    @body = "The full price of the book '#{record.book.title.truncate(30)}',amount of $#{record.book.price.to_f} was paid to you. Please check your balance -CampusWise"
    TwilioRequest.send_sms(@body, @to)    
  end

  def self.borrower_full_price_charged(record) #exchange
    @admin_notification = record.dashboard_notifications.new(
      :admin_user_id => AdminUser.first.id,
      :content => "User: #{record.user.name} with email:#{record.user.email}, was charged $#{record.book.price.to_f} successfully for not returning the book <a href='/admin/books/#{record.book.id}'>#{record.book.title.truncate(50)}</a>"
    )
    @admin_notification.save

    @dashboard = record.dashboard_notifications.new(
      :user_id => record.user.id,
      :content => "Because you did not return the book titled '<a href='/books/#{record.book.id}'>#{record.book.title}</a>' back to your fellow student, we have charged $#{record.book.price.to_f} from you."
    )
    @dashboard.save
    Notification.borrower_full_price_charged(record).deliver
    @to = record.user.phone
    @body = "Because you did not return the book titled '#{record.book.title.truncate(30)}' back to your fellow student, we have charged $#{record.book.price.to_f} from you. -CampusWise"
    TwilioRequest.send_sms(@body, @to)  
  end

  def self.offering_a_requested_book(requested_book_id, added_book_id)
    @book = Book.find(requested_book_id)
    @dashboard = DashboardNotification.new(
      :user_id => @book.user.id,
      :content => "Someone is offering your requested book '<a href='/books/#{@book.id}'>#{@book.title}</a>'. To get the book click <a href='/books/#{added_book_id}'>here</a>."
    )
    @dashboard.save
    Notification.offering_a_requested_book(requested_book_id, added_book_id).deliver
    @to = @book.user.phone
    @body = "Someone is offering your requested book '#{@book.title.truncate(30)}',to get this book login our site. -CampusWise"
    TwilioRequest.send_sms(@body, @to)
  end
end