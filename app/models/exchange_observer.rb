class ExchangeObserver < ActiveRecord::Observer
  observe :exchange, :book, :payment

  def helpers
    ActionController::Base.helpers
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
      if record.counter_offer.present? and record.counter_offer_last_made_by.present?
        if record.amount_was.to_f < record.amount.to_f
          return false
        end
        if record.counter_offer_was.to_f > record.counter_offer.to_f
          return false
        end

        if record.amount.to_f < record.counter_offer.to_f
          return false
        end
      end
    end

    if record.class == Payment
      if record.status == Payment::STATUS[:paid] and record.status_was == Payment::STATUS[:pending] and record.exchange.payments.count == 1
        #  Notify.delay.borrower_about_payment_received(record)
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
          @service_fee = @amount * Constant::COMPANY_COMMISION_RATE.to_f/100
          
          # earned money by selling/renting book
          @transaction0 = @exchange.build_transaction(:user_id => @payment_receiver.id,
            :description => "#{@exchange.package == "buy" ? "Sold" : "Lent"} book titled '#{@exchange.book.title}'.",
            :credit => @amount,
            :debit => 0.0,
            :amount => @payment_receiver.transactions.present? ? (@payment_receiver.transactions.last.amount.to_f + @amount.to_f)  : @amount.to_f)
          if @transaction0.save
            # company commission deducted
            @transaction1 = @exchange.build_transaction(:user_id => @payment_receiver.id,
              :description => "CampusWise fee(#{Constant::COMPANY_COMMISION_RATE}%) for #{@exchange.package == "buy" ? "sell" : "lend"} of book titled '#{@exchange.book.title}'.",
              :credit => 0.0,
              :debit => @service_fee,
              :amount => @transaction0.amount.to_f - @service_fee.to_f)
            if @transaction1.save
              #update exchange attribute incase the book is deleted
              @exchange.update_attributes(:owner_id => @payment_receiver.id, :book_title => @requested_book.title)
            end
          end
          Notify.delay.borrower_after_exchange_complete(record)
          Notify.delay.owner_after_exchange_complete(record)
          record.exchange.destroy_other_pending_requests
          unless record.exchange.package == "buy"
            @returning_date = (@exchange.ending_date.to_date - Date.today)
            @sending_date = @returning_date.days.from_now
            Delayed::Job.enqueue Jobs::ReminderJob.new(record), 0 , @sending_date, :queue => "book_return_reminder"
          end
        else
          # full book charge
          if @exchange.status == Exchange::STATUS[:charge_pending]
            @payment_receiver = @exchange.book.user
            @exchange.update_attributes(:status => Exchange::STATUS[:charged])            
            @transaction = @exchange.build_transaction(:user_id => @payment_receiver.id,
              :description => "Received full book price of book titled '#{@exchange.book.title.truncate(40)}'.",
              :credit => @exchange.book.price.to_f,
              :debit => 0.0,
              :amount => @payment_receiver.transactions.last.amount.to_f + @exchange.book.price.to_f)
            @transaction.save
            if @transaction.save
              Notify.delay.owner_full_price_charged(@exchange)
              Notify.delay.borrower_full_price_charged(@exchange)
            end
          end
        end
      elsif record.status == Payment::STATUS[:failed]
        if record.exchange.book.available == true
          record.exchange.destroy
        elsif record.exchange.book.available == false
          record.exchange.update_attribute(:status, Exchange::STATUS[:full_charge_failed])
        end    
      end
    end
    
    if record.class == Exchange
      if record.counter_offer.present? and record.status == Exchange::STATUS[:pending]
        if record.counter_offer_last_made_by == record.book.user.id and record.amount_was > record.amount.to_f and record.counter_offer_count > 0
          @dashboard = DashboardNotification.find_by_dashboardable_id_and_user_id(record.id, record.book.user.id)
          @dashboard.update_attribute(:seen, true) if @dashboard.present?
        elsif record.counter_offer_last_made_by == record.user.id  and record.counter_offer_was < record.counter_offer.to_f
          @dashboard = DashboardNotification.find_by_dashboardable_id_and_user_id(record.id, record.user.id)
          @dashboard.update_attribute(:seen, true) if @dashboard.present?
        end
      end
    end
  end


  def before_destroy(record)
    if record.class == Exchange
      if record.status == Exchange::STATUS[:accepted]
        return false
      else
        if record.payments.blank? and record.declined.present?
          Notify.borrower_about_card_rejected(record)
        elsif record.payments.present? and record.payments.first.status == Payment::STATUS[:failed]
          if record.book.available == true
            Notify.borrower_about_card_problem(record)
          end
        end
      end
    end 
  end
end