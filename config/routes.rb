Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  # root 'dashboard#index'
  root to: 'site#index'
  resources :messages
  resources :categories
  namespace :api do
    namespace :v1 do
      resources :messages, only: %i[
        index
        create
        destroy
        update
        reply
      ] do
        collection do
          get 'reply'
        end
      end
    end
  end
end
