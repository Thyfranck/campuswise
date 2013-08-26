ActiveAdmin.register WithdrawRequest do
  config.per_page = 50

  actions :all, :except => [:new, :edit, :destroy]

  action_item only:[:show] do
    link_to "Pay", pay_form_admin_user_path(withdraw_request.user)
  end

  index do
    selectable_column
    column :id
    column :user
    column :amount
    column :payment_method
    column :status
    column :created_at
    column :updated_at
    default_actions
  end

  show do |registration|
    attributes_table do
      row :id
      row :user
      row :amount
      row :payment_method
      row :status
      row :created_at
      row :updated_at
      row "Withdrawal Information" do |wr|
        wr.user.payment_method_info(wr.payment_method).html_safe
      end
    end
  end

end