Bookcuddle::Application.routes.draw do
  get "sessions/new"

  resources :users
  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'authorized', to: 'users#authorized', as: 'authorized'
  root :to => 'users#index'

  resources :sessions
end
