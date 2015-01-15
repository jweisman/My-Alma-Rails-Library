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

  resources :deposits do
    get :confirm, to: 'deposits#confirm', as: 'confirm'
    get :submit, to: 'deposits#submit', as: 'submit'
    resources :filestreams, :only => [:index, :create, :destroy] do
      get :generate_key, :on => :collection
    end
  end

  # Authentication routes
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'

end

