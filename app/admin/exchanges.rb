ActiveAdmin.register Exchange do
  config.per_page = 50
  actions :all, :except => [:new, :edit, :delete]

  filter :user
  filter :status
  filter :starting_date
  filter :ending_date
  filter :created_at

  index do
    selectable_column
    column :id
    column "Book owner Email" do |exchange|
      exchange.book.user.email
    end
    column "Book borrower Email" do |exchange|
      exchange.user.email
    end   
    column :status
    column :package do |e|
      e.package == "buy" ? "Sold" : "Borrowed"
    end
    column :starting_date
    column :ending_date
    column :created_at
    default_actions
  end

  show do |exchange|
    attributes_table do
      row :id
      row "Book owner Name" do |exchange|
        exchange.book.user.name
      end
      row "Book borrower Name" do |exchange|
        exchange.user.name
      end
      row :package
      row :starting_date
      row :ending_date
      row :created_at
      row :dropped_off
      row :dropped_off_at
      row :received
      row :received_at
      row :status
      if exchange.status == Exchange::STATUS[:not_returned]
        row "Charge Book Borrower" do
          link_to("Charge Book Borrower", charge_admin_exchange_path(exchange) , :confirm => "Are you sure want to charge the book borrower with book price ($#{exchange.book.price.to_f})?")
        end
      end
    end
  end

  member_action :charge do
    @exchange = Exchange.find(params[:id])
    @price = @exchange.book.price.to_f
    begin
      response = @exchange.user.billing_setting.charge(@price, "Full book price charge - #{@price}")
      @payment = @exchange.payments.new(:payment_amount => @price, :charge_id => response.id, :status => Payment::STATUS[:pending])
      if @payment.save
        @exchange.update_attributes(:status => Exchange::STATUS[:charge_pending])
        redirect_to admin_exchange_path(@exchange), :notice => "Request is in process"
      end
    rescue => e
      logger.error e.message
      redirect_to admin_exchange_path(@exchange), :notice => "#{e.message}"
    end
  end  
end
