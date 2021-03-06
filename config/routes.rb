Bookcuddle::Application.routes.draw do

  root :to => 'users#index'

  resources :discussions, :only => [:create, :destroy, :new, :show, :index]
  resources :users
  resources :sessions, :only => [:create, :destroy]
  resources :books, :only => [:create, :show]

  post 'quotes', to: 'discussions#quote', as: 'quote'
  post 'progress', to: 'discussions#progress', as: 'progress'
  get 'friends', to: 'users#friends', as: 'friends'
  get 'compare/:friend_goodreads_id', to:'users#compare', as:'compare'
  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
  get 'authorized', to: 'sessions#authorized', as: 'authorized'
  get 'about', to: 'static_pages#about', as: 'about'
  get 'contact', to: 'static_pages#contact', as: 'contact'
end
