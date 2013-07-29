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
        if record.amount_was < record.amount.to_f
          return false
        end
        if record.counter_offer_was > record.counter_offer.to_f
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
          @will_be_paid_to_user = @amount - (@amount/Constant::COMPANY_COMMISION_RATE)
          @will_be_paid_to_user = @will_be_paid_to_user.to_f
          @old_credit = @payment_receiver.credit.to_f or 0.0
          @new_credit = @old_credit + @will_be_paid_to_user
          @payment_receiver.update_attribute(:credit, @new_credit)
          
          if @exchange.package == 'buy'
            @transaction = @exchange.build_transaction(:user_id => @payment_receiver.id,
              :description => "Sold book titled '#{@exchange.book.title}' at #{@exchange.updated_at.to_date} and received amount of #{helpers.number_to_currency(@will_be_paid_to_user, :prescision => 2)}",
              :amount => @will_be_paid_to_user)
            @transaction.save
            @exchange.update_attributes(:owner_id => @payment_receiver.id, :book_title => @requested_book.title)
          else
            @transaction = @exchange.build_transaction(:user_id => @payment_receiver.id,
              :description => "Lend the book titled '#{@exchange.book.title}' at #{@exchange.updated_at.to_date} for #{@exchange.package == 'semester' ? "full semester" : (@exchange.duration.to_s + " " + @exchange.package).pluralize(@exchange.duration)} and received amount of #{helpers.number_to_currency(@will_be_paid_to_user, :prescision => 2)}",
              :amount => @will_be_paid_to_user)
            @transaction.save
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
          if @exchange.status == Exchange::STATUS[:charge_pending]
            @exchange.update_attributes(:status => Exchange::STATUS[:charged])
            @payment_receiver = @exchange.book.user
            @old_credit = @payment_receiver.credit.to_f or 0.0
            @new_credit = @old_credit + @exchange.book.price.to_f
            if @payment_receiver.update_attribute(:credit, @new_credit)
              @transaction = @exchange.build_transaction(:user_id => @payment_receiver.id,
                :description => "Received amount of #{helpers.number_to_currency(@exchange.book.price.to_f, :prescision => 2)} for not receiving the book titled '#{@exchange.book.title.truncate(40)}' in time.",
                :amount => @exchange.book.price.to_f)
              @transaction.save
              Notify.delay.owner_full_price_charged(@exchange)
            end
            Notify.delay.borrower_full_price_charged(@exchange)
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