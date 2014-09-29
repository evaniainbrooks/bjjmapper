Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  resources :users, :only => [:show, :create, :update]
  resources :teams, :only => [:show, :index]
  root 'application#map'

  # TEMPORARY PODIUM WEBSTORE TEST REMOVE
  get '/webstore' => 'application#webstore'

  get 'search/:query' => 'application#search'
  match '/signin' => 'sessions#new', :as => :signin, :via => [:post, :get]
  match '/auth/:provider/callback' => 'sessions#create', :via => [:post, :get]
  match '/auth/failure' => 'sessions#failure', :via => [:post, :get]
  match '/signout' => 'sessions#destroy', :as => :signout, :via => [:post, :get, :delete]
  
  get '/meta' => 'application#meta', :as => :meta
  get '/people' => 'application#people'
  post '/contact' => 'application#contact', :as => :contact

  resources :locations do
    get :search, on: :collection
    get :geocode, on: :collection
  end
end
