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

  resource :catalog, only: [:show], controller: 'catalog' do
    get 'availability'
    get 'admin'
    get 'harvest'
  end

  # Authentication routes
  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'

end

