Campuswise::Application.routes.draw do
  root :to => "static#home"
  
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  match "home"     => "static#home"

  
end
