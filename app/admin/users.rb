ActiveAdmin.register User do
  config.per_page = 50
  
  filter :name
  filter :email
  filter :phone
  filter :facebook
  filter :activation_state

  index do
    selectable_column
    column :id
    column :email
    column :name
    column :phone
    column :facebook
    column :activation_state
    column "Manage" do |user|
      link_to "Login", login_admin_user_path(user), :target => "_blank"
    end
    default_actions
  end

  show do |user|
    attributes_table do
      row :id
      row :school
      row :name
      row :email
      row :phone
      row :facebook
      row :credit
      row :debit
      row :activation_state
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
  
  action_item only:[:show] do
    link_to "Pay", pay_form_admin_user_path(user)
  end
  
  member_action :login do
    @user = User.find(params[:id])
    auto_login @user
    redirect_to @user
  end

  member_action :pay_form do
    @user = User.find(params[:id])
    @pending_request = @user.withdraw_requests.where(:status => WithdrawRequest::STATUS[:pending])
    if @pending_request.present?
      @requested_amount = @pending_request.first.amount.to_f
    else
      redirect_to admin_user_path(@user), :notice => 'No pending Withdraw request or already paid.'
    end
  end

  member_action :pay, :method => :post do
    @user = User.find(params[:id])
    if @request = @user.withdraw_requests.where(:status => WithdrawRequest::STATUS[:pending]).present?
      if params[:amount].present? and @user.credit.to_f > params[:amount].to_f
        @new_credit = @user.credit.to_f - (@user.debit.to_f + params[:amount].to_f)
        if @new_credit.to_f > 0
          @new_debit = (@user.debit.to_f or 0.0) + params[:amount].to_f
          if @user.update_attribute(:debit, @new_debit)
            @request = @user.withdraw_requests.where(:status => WithdrawRequest::STATUS[:pending]).first
            @request.update_attribute(:status,WithdrawRequest::STATUS[:paid])
            @request.dashboard_notifications.first.destroy
            Notify.delay.user_for_withdraw(@request)
            redirect_to admin_user_path(@user)
            flash[:notice] = "Request Completed"
          end
        else
           redirect_to admin_user_path(@user), :notice => "Insufficient fund"
        end
      end
    else
      redirect_to admin_user_path(@user)
      flash[:notice] = "No pending Withdraw request or already paid."
    end
  end
end
