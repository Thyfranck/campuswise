class ExchangeObserver < ActiveRecord::Observer
  observe :exchange, :book, :payment

  def after_save(record)
    if record.class == Payment
      Notify.delay.borrower_about_payment_received(record)
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
      Notify.delay.owner_about_new_request(record)
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
        @requested_book = @exchange.book
        if @requested_book.available == true
          @exchange.update_attribute(:status, Exchange::STATUS[:accepted])
          @requested_book.update_attribute(:available, false)
          Notify.delay.borrower_after_exchange_complete(record)
          Notify.delay.owner_after_exchange_complete(record)
          record.exchange.destroy_other_pending_requests
          @returning_date = (@exchange.ending_date.to_date - Date.today)
          @sending_date = @returning_date.days.from_now
          Delayed::Job.enqueue Jobs::ReminderJob.new(record), 0 , @sending_date, :queue => "book_return_reminder"
        end
      elsif record.status == Payment::STATUS[:failed]
        record.exchange.destroy
      end
    end
    
    if record.class == Exchange
      if record.status == Exchange::STATUS[:returned]
        @admin_notification = DashboardNotification.new(
          :admin_user_id => AdminUser.first.id,
          :exchange_id => record.id,
          :content => "User: #{record.book.user.name} with email:#{record.book.user.email} says that he has got return the book \"<a href='/admin/books/#{record.book.id}'>#{record.book.title.truncate(50)}</a> \" "
        )
        @admin_notification.save
      end

      if record.status == Exchange::STATUS[:not_returned]
        @admin_notification = DashboardNotification.new(
          :admin_user_id => AdminUser.first.id,
          :exchange_id => record.id,
          :content => "User: #{record.book.user.name}, email:#{record.book.user.email} says that didn't got back the book \"<a href='/admin/books/#{record.book.id}'>#{record.book.title.truncate(50)}</a> \" "
        )
        @admin_notification.save
      end
    end    
  end


  def before_destroy(record)
    if record.class == Book
      return false if record.lended == true
      @exchanges = Exchange.where(:book_id => record.id)
      @notification = DashboardNotification.where(:exchange_id => @exchanges)
      @notification.each {|d| d.destroy}
      @exchanges.each {|d| d.destroy}
    end
  end
end