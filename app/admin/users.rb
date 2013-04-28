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

  member_action :login do
    @user = User.find(params[:id])
    auto_login @user
    redirect_to @user
  end
end
