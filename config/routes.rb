Rails.application.routes.draw do
  resources :mains
  root 'mains#new'
end
