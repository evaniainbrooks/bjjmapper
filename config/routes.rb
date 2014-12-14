Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  resources :users, :only => [:show, :create, :update] do
    resources :users, controller: :students, as: :students, path: '/students', only: [:create, :destroy, :index]
  end
  resources :locations do
    get :search, on: :collection
    get :nearby, on: :member
    get :schedule, on: :member
    resources :events
    resources :users, controller: :instructors, as: :instructors, path: '/instructors', only: [:create, :destroy, :index]
  end
  resources :teams, :only => [:show, :index, :update]
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
end
