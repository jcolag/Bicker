Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  #root 'dashboard#index'
  root to: 'site#index'
  resources :messages
  resources :categories
  namespace :api do
    namespace :v1 do
      resources :messages, only: [:index, :create, :destroy, :update]
    end
  end
end
