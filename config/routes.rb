Campuswise::Application.routes.draw do

  post 'stripe-webhook' => 'stripe_webhook#create'

  resources :books do
    collection do
      get :available
      get :requested
    end
  end

  resources :exchanges, :except => [:show, :index] do
    member do
      get :returned
    end
    collection do
      get :search
    end
  end

  match '/search' => 'books#search', :as => :search
  match '/show_search' => 'books#show_search'
  match '/dashboard' => 'users#dashboard'
  match '/remove_notification' => 'users#remove_notification'
  match '/borrow_requests' => 'users#borrow_requests'
  match '/smsresponse' => 'exchanges#process_sms'

  match 'school-home' => 'static#school_home', :as => :school_home

  resources :billing_settings, :except => [:index]
  
  resources :users, :except => [:index] do
    member do
      get :activate
      get :change_password
      get :sms_verification
      post :verify_code
      get :send_verification_sms
      get :payment
    end
  end

  resources :sessions, :only => [:create]

  match 'login' => 'sessions#new', :as => :login
  match 'logout' => 'sessions#destroy', :as => :logout

  resources :password_resets, :only => [:create, :edit, :update, :new]

  root :to => "static#home"

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
end
