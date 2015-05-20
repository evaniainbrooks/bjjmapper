Rails.application.routes.draw do
  namespace :admin do
    resources :locations, only: [:index] do
      get :meta, on: :member
    end
  end

  resources :users, :only => [:index, :show, :create, :update] do
    get :reviews, on: :member
    resources :users, controller: :students, as: :students, path: '/students', only: [:create, :destroy, :index]
  end
  resources :locations do
    get :search, on: :collection
    get :wizard, on: :collection
    get :recent, on: :collection
    get :nearby, on: :member
    get :schedule, on: :member
    post :move, on: :member
    resources :reviews, only: [:create, :destroy, :index]
    resources :events, only: [:create, :index, :show, :destroy, :update] do
      post :move, on: :member
    end
    resources :users, controller: :instructors, as: :instructors, path: '/instructors', only: [:create, :destroy, :index]
  end
  resources :teams, :only => [:show, :index, :update, :create, :new] do
    post :remove_image, on: :member
  end
  root 'application#homepage'

  get '/omnischedule' => 'events#omnischedule', :as => :omnischedule
  
  get 'search/:query' => 'application#search'
  get '/bjj-academy-directory(/country/:country(/city/:city))' => 'locations#index', :as => :directory_index
  match '/signin' => 'sessions#new', :as => :signin, :via => [:post, :get]
  match '/auth/:provider/callback' => 'sessions#create', :via => [:post, :get]
  match '/auth/failure' => 'sessions#failure', :via => [:post, :get]
  match '/signout' => 'sessions#destroy', :as => :signout, :via => [:post, :get, :delete]

  post '/report' => 'application#report', :as => :report
  get '/map' => 'application#map', :as => :map
  get '/meta' => 'application#meta', :as => :meta
  get '/people' => 'application#people'
  get '/geocode' => 'application#geocode'
  post '/contact' => 'application#contact', :as => :contact

  post '/paroscamp/contact' => 'paroscamp#contact'

  get '/sitemap.xml' => 'sitemaps#index', :format => 'xml', :as => :sitemap
end
