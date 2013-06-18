ActiveAdmin.register WithdrawRequest do
  config.per_page = 50

  actions :all, :except => [:new, :edit, :destroy]

  action_item only:[:show] do
    link_to "Pay", pay_form_admin_user_path(withdraw_request.user)
  end

end