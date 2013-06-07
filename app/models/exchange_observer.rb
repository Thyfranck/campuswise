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

      if record.counter_offer.present? and record.counter_offer_last_made_by.present?
        if record.counter_offer_last_made_by_was == record.counter_offer_last_made_by #making sure that one user doesn't the negotiation twice at a time.
          return false
        end
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
          @payment_receiver = record.exchange.book.user
          @amount = record.payment_amount.to_f
          @will_be_paid_to_user = @amount - (@amount/Constant::COMPANY_COMMISION_RATE)
          if @payment_receiver.balance.present?
            @old_balance = record.exchange.book.user.balance
            @new_balance = @old_balance + @will_be_paid_to_user
            @payment_receiver.update_attribute(:balance, @new_balance)
          else
            @payment_receiver.update_attribute(:balance, @amount)
          end
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
        Notify.admin_for_book_returned(record)
      elsif record.status == Exchange::STATUS[:not_returned]
        Notify.admin_for_book_not_returned(record)
      elsif record.counter_offer.present?
        if record.counter_offer_last_made_by == record.book.user.id
          Notify.borrower_about_owner_want_to_negotiate(record)
        elsif record.counter_offer_last_made_by == record.user.id
          Notify.owner_about_borrower_want_to_negotiate(record)
        end
      end
    end    
  end


  def before_destroy(record)
    if record.class == Book
      return false if record.lended == true
      ##      @exchanges = Exchange.where(:book_id => record.id)
      ##      @notification = DashboardNotification.where(:dashboardable => @exchanges)
      ##      @notification.each {|d| d.destroy}
      ##      @exchanges.each {|d| d.destroy}
    end

    if record.class == Exchange
      if record.counter_offer.present?
        Notify.owner_about_negotiation_failed(record)
      else
        if record.payment.blank? and record.declined.present?
          Notify.borrower_about_card_rejected(record)
        elsif record.payment.blank?
          Notify.borrower_about_rejected_by_owner(record)
        elsif record.payment.status == Payment::STATUS[:failed]
          if record.book.available == true
            Notify.borrower_about_card_problem(record)
          end
        end
      end
    end
  end
end