class ExchangeObserver < ActiveRecord::Observer
  observe :exchange, :book, :payment

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
      if record.payment.present?
        if record.payment.status == Payment::STATUS[:paid]
          return true
        else
          return false
        end
      end
      if record.counter_offer.present? and record.counter_offer_last_made_by.present?
        if record.amount_was < record.amount
          return false
        end
        if record.counter_offer_was > record.counter_offer
          return false
        end

        if record.amount < record.counter_offer
          return false
        end
      end
    end

    if record.class == Payment
      if record.status == Payment::STATUS[:paid] and record.status_was == Payment::STATUS[:pending]
        Notify.delay.borrower_about_payment_received(record)
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
          begin
            Notify.borrower_after_exchange_complete(record)
            Notify.owner_after_exchange_complete(record)
          rescue
          end
          record.exchange.destroy_other_pending_requests
          unless record.exchange.package == "buy"
            @returning_date = (@exchange.ending_date.to_date - Date.today)
            @sending_date = @returning_date.days.from_now
            Delayed::Job.enqueue Jobs::ReminderJob.new(record), 0 , @sending_date, :queue => "book_return_reminder"
          end
        end
      elsif record.status == Payment::STATUS[:failed]
        record.exchange.destroy
      end
    end
    
    if record.class == Exchange
      if record.status == Exchange::STATUS[:returned]
        Notify.delay.admin_for_book_returned(record)
      elsif record.status == Exchange::STATUS[:not_returned]
        Notify.delay.admin_for_book_not_returned(record)
      elsif record.counter_offer.present?
        if record.counter_offer_last_made_by == record.book.user.id and record.amount_was == record.amount
          Notify.delay.borrower_about_owner_doesnt_want_to_negotiate(record, record.counter_offer_was)
        end
        if record.counter_offer_last_made_by == record.book.user.id and record.amount_was > record.amount and record.counter_offer_count > 0
          Notify.delay.borrower_about_owner_want_to_negotiate(record)
          @dashboard = DashboardNotification.find_by_dashboardable_id_and_user_id(record.id, record.book.user.id)
          @dashboard.destroy if @dashboard.present?
        elsif record.counter_offer_last_made_by == record.user.id  and record.counter_offer_was < record.counter_offer
          @dashboard = DashboardNotification.find_by_dashboardable_id_and_user_id(record.id, record.user.id)
          @dashboard.destroy if @dashboard.present?
          Notify.delay.owner_about_borrower_want_to_negotiate(record)
        end
      end
    end
  end


  def before_destroy(record)
    if record.class == Exchange
      if record.status == Exchange::STATUS[:accepted]
        return false
      else
        if record.counter_offer.present? and record.counter_offer_count == 0
          Notify.borrower_about_rejected_by_owner(record)
        elsif record.counter_offer.present? and record.counter_offer_count > 0
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
    if record.class == Book
      return false if record.lended == true
    end

    
  end
end