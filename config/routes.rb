Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  resources :users, :only => [:show, :edit, :update]
  root 'locations#index'

  # TEMPORARY PODIUM WEBSTORE TEST REMOVE
  get '/webstore' => 'application#webstore'

  get 'search/:query' => 'application#search'
  match '/signin' => 'sessions#new', :as => :signin, :via => [:get]
  match '/auth/:provider/callback' => 'sessions#create', :via => [:post, :get]
  match '/auth/failure' => 'sessions#failure', :via => [:post, :get]
  match '/signout' => 'sessions#destroy', :as => :signout, :via => [:post, :get, :delete]
  
  get '/meta' => 'application#meta'
  get '/teams' => 'application#teams'
  get '/people' => 'application#people'

  resources :locations do
    get :search, on: :collection
    get :geocode, on: :collection
  end
end
