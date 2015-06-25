Rails.application.routes.draw do
  resources :mains
  resources :users, :only => [:new, :create]
  resources :sessions, :only => [:new, :create, :destroy]
  root 'users#index'

  match "/signout", :to => 'sessions#destroy', via: [:get]
end
