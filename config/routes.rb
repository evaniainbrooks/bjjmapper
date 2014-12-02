Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  resources :users, :only => [:show, :create, :update]
  resources :teams, :only => [:show, :index]
  root 'application#map'

  get 'search/:query' => 'application#search'
  match '/signin' => 'sessions#new', :as => :signin, :via => [:post, :get]
  match '/auth/:provider/callback' => 'sessions#create', :via => [:post, :get]
  match '/auth/failure' => 'sessions#failure', :via => [:post, :get]
  match '/signout' => 'sessions#destroy', :as => :signout, :via => [:post, :get, :delete]

  post '/report' => 'application#report', :as => :report
  get '/meta' => 'application#meta', :as => :meta
  get '/people' => 'application#people'
  get '/geocode' => 'application#geocode'
  post '/contact' => 'application#contact', :as => :contact

  get '/sitemap.xml' => 'sitemaps#index', :format => 'xml', :as => :sitemap

  resources :locations do
    get :search, on: :collection
    get :nearby, on: :member
    resources :events
    resources :users, controller: :instructors, as: :instructors, path: '/instructors', only: [:create, :destroy]
  end
end
