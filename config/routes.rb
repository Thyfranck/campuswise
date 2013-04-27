Campuswise::Application.routes.draw do


  resources :books


  get "password_resets/create"

  get "password_resets/edit"

  get "password_resets/update"

  match "home"     => "static#home"

  match 'school-home' => 'static#public_find_books', :as => :find
  
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
