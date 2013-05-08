Campuswise::Application.routes.draw do


  resources :books

  resources :exchanges


  get "password_resets/create"

  get "password_resets/edit"

  get "password_resets/update"

  match "home"     => "static#home"

  match 'school-home' => 'static#public_find_books', :as => :find
  match '/search' => 'books#search', :as => :search
  match '/public_search' => 'static#public_search'
  match '/show_search' => 'books#show_search'
  match '/show_public' => 'static#show_public'
  match '/search_for_borrow' => 'books#search_for_borrow'
  match '/dashboard' => 'users#dashboard'
  match '/remove_notification' => 'users#remove_notification'
  match '/borrow_requests' => 'users#borrow_requests'
  match '/requested_books' => 'books#requested_books'

  
  resources :users, :except => [:index] do
    member do
      get :activate
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
