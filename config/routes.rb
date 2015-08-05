Rails.application.routes.draw do
  
  root 'home#index'

  resource :home, only: [:index]

  resources :fines, only: [:index] do
    collection do
      get 'pay'
      get 'confirm'
      get 'validate'
    end
  end

  resources :requests, only: [:index] do
    get 'cancel', on: :member
  end

  resource :card, only: [:show, :update], controller: 'card'
  
  resources :collections, only: [:index, :show] do
    get 'titles', on: :member
  end

  resources :deposits do
    get :confirm, to: 'deposits#confirm', as: 'confirm'
    get :submit, to: 'deposits#submit', as: 'submit'
    resources :filestreams, :only => [:index, :create, :destroy] do
      get :generate_key, :on => :collection
    end
  end

  resource :catalog, only: [:show], controller: 'catalog' do
    get 'availability'
    get 'admin'
    get 'harvest'
  end

  # Authentication routes
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'
  get 'login', to: 'sessions#login', as: 'login'

end

