class StripeWebhookController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def create
    begin
      types = %w(charge.succeeded charge.failed charge.refunded charge.dispute.created charge.dispute.updated charge.dispute.closed)

      if types.include?(params["type"])
        payment = Payment.find_by_charge_id(params["data"]["object"]["id"])
        exchange = payment.exchange

        BillingEvent.create(
          :event_type  => params["type"],
          :user_id     => exchange.user.present? ? exchange.user_id : nil,
          :payment_id  => payment.id,
          :response    => params["data"]["object"]
        )
      end
    rescue => e
      error = e
    end

    respond_to do |format|
      if error.blank?
        format.any { render :text => "SUCCESS", :status => :ok }
      else
        format.any { render :text => "ERROR", :status => :bad_request }
      end
    end
  end
end
