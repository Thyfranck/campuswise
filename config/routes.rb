Campuswise::Application.routes.draw do
  root :to => "static#home"
  
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  match "home"     => "static#home"

  match '/static/find' => 'static#find'

  resources :users, :except => [:index] do
    member do
      get :activate
    end
  end

  resources :sessions, :only => [:create]

  match 'login' => 'sessions#new', :as => :login
  match 'logout' => 'sessions#destroy', :as => :logout
end
