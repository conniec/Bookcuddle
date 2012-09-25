Bookcuddle::Application.routes.draw do

  root :to => 'users#index'
  
  resources :discussions, :only => [:create, :destroy, :new]
  resources :users
  resources :sessions, :only => [:create, :destroy]
  
  get 'friends', to: 'users#friends', as: 'friends'  
  get 'compare/:friend_goodreads_id', to:'users#compare', as:'compare'
  get 'discussions/create', to:'discussions#create', as: 'create_discussion'
  get 'discussions/:id', to:'discussions#show', as: 'show_discussion'
  get 'signup', to: 'users#new', as: 'signup'
  get 'edit/', to: 'users#edit', as: 'edit_user'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'authorized', to: 'sessions#authorized', as: 'authorized'
  get 'isuser/:goodreads_id', to: 'users#is_user?', as: 'is_user'
end
