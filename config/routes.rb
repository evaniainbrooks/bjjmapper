Rails.application.routes.draw do
  namespace :api do
    resources :locations, only: [:index, :create]
  end
  
  namespace :admin do
    resources :directory_segments, only: [:new, :create, :edit, :update]
    resources :organizations, only: [:new, :create]
    resources :locations, only: [:index, :show] do
      get :pending, on: :collection
      get :rejected, on: :collection
      get :moderate, on: :collection
    end
    resources :users do
      get :edit_merge, on: :member
      post :merge, on: :member
    end
    resources :templates, only: [:show]
  end

  resources :users, :only => [:index, :show, :create, :update, :destroy] do
    post :remove_image, on: :member
    resources :users, controller: :students, as: :students, path: '/students', only: [:create, :destroy, :index]
    resources :events, controller: :user_events, only: [:index]
    resources :reviews, controller: :user_reviews, only: [:index]
  end

  resource :map, only: [:show] do
    get :search, on: :collection
  end

  resource :geocoder, only: [:show]

  resources :locations, only: [:create, :destroy, :update, :show] do
    post :favorite, on: :member
    get :wizard, on: :collection
    get :recent, on: :collection
    get :nearby, on: :collection
    get :search, on: :collection, controller: :search_locations, action: 'show'
    get :schedule, on: :member

    post :move, on: :member
    post :unlock, on: :member
    post :close, on: :member

    resource :status, controller: :location_statuses, only: [] do
      put :verify, on: :member
      put :reject, on: :member
      put :pending, on: :member
    end

    resources :reviews, controller: :location_reviews, only: [:create, :destroy, :index]

    resources :users, controller: :instructors, as: :instructors, path: '/instructors', only: [:create, :destroy, :index]

    resources :events, controller: :location_events, only: [:create, :index, :show, :destroy, :update] do
      post :move, on: :member
    end
  end

  resources :verifications, controller: :location_owner_verifications, as: :verifications, path: '/verifications', only: [:create] do
    get :verify, on: :member
  end

  resources :teams, :only => [:show, :index, :update, :create, :new, :destroy] do
    post :remove_image, on: :member
    resources :users, controller: :instructors, as: :instructors, path: '/instructors', only: [:create, :destroy, :index]
  end

  resources :events, :only => [:index, :create] do
    get :wizard, on: :collection
    get :upcoming, on: :collection
  end

  root 'application#homepage'
  get '/bjj-academy-directory' => 'directory_segments#index', :as => :directory_index
  get '/bjj-academy-directory/country/:country(/city/:city)' => 'directory_segments#show', :as => :directory_segment

  match '/signin' => 'sessions#new', :as => :signin, :via => [:post, :get]
  match '/auth/:provider/callback' => 'sessions#create', :via => [:post, :get]
  match '/auth/failure' => 'sessions#failure', :via => [:post, :get]
  match '/signout' => 'sessions#destroy', :as => :signout, :via => [:post, :get, :delete]

  post '/report' => 'application#report', :as => :report
  get '/meta' => 'application#meta', :as => :meta
  get '/privacy-policy' => 'application#privacy_policy', :as => :privacy_policy
  get '/people' => 'application#people'
  post '/contact' => 'application#contact', :as => :contact

  get '/sitemap.xml' => 'sitemaps#index', :format => 'xml', :as => :sitemap
end
