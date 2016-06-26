Rails.application.routes.draw do
  
  root 'home#index'

  resource :home, only: [:index]

  resources :fines, only: [:index] do
    collection do
      get :pay
      get :confirm
      get :validate
    end
  end

  resources :requests, only: [:index] do
    get :cancel, on: :member
  end

  resource :card, only: [:show, :update], controller: 'card'
  
  resources :collections, only: [:index, :show] do
    resources :titles, only: [:index, :show], to: 'collections#titles'
  end

  resources :deposits do
    resources :files, only: :destroy, to: 'deposits#delete_file'
  end

  resource :catalog, only: [:show], controller: 'catalog' do
    get :availability
    get :admin
    get :harvest
  end

  # Authentication routes
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
  get 'login', to: 'sessions#login', as: 'login'

end

