Campuswise::Application.routes.draw do

  resources :withdraw_requests, :only => [:new, :create, :index]
  resources :payment_methods


  post 'stripe-webhook' => 'stripe_webhook#create'

  resources :books do
    collection do
      get :available
      get :requested
      get :campus_bookshelf
    end
  end

  resources :exchanges, :only => [:new, :create, :update, :destroy] do
    member do
      get :returned
      get :before
    end
    collection do
      get :search
    end
  end

  match '/search' => 'books#search', :as => :search
  match '/notification' => 'users#notification_count'
  match '/show_search' => 'books#show_search'
  match '/dashboard' => 'users#dashboard'
  match '/remove_notification' => 'users#remove_notification'
  match '/borrow_requests' => 'users#borrow_requests'
  match '/smsresponse' => 'exchanges#process_sms'

  match 'school-home' => 'static#school_home', :as => :school_home

  resources :billing_settings, :except => [:index, :destroy]
  
  resources :users, :except => [:index] do
    member do
      get :activate
      get :change_password
      get :sms_verification
      post :verify_code
      get :send_verification_sms
      get :payment
      get :wallet
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
