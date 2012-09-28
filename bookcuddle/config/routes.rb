Bookcuddle::Application.routes.draw do

  root :to => 'users#index'
  
  resources :discussions, :only => [:create, :destroy, :new, :show, :index]
  resources :users
  resources :sessions, :only => [:create, :destroy]
  resources :books, :only => [:create]
  
  get 'friends', to: 'users#friends', as: 'friends'  
  get 'compare/:friend_goodreads_id', to:'users#compare', as:'compare'
  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'authorized', to: 'sessions#authorized', as: 'authorized'
end
