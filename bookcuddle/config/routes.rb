Bookcuddle::Application.routes.draw do
  root :to => 'users#index'
  
  resources :users
  resources :sessions, :only => [:create, :destroy]
  
  get 'friends', to: 'users#friends', as: 'friends'  
  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'authorized', to: 'sessions#authorized', as: 'authorized'
end
