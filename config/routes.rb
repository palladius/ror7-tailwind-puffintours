Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks'
  }


  resources :articles do
    resources :comments
  end
  get "/tags/:tag" => "articles#index", as: :tag
  resource :user, only: %i[edit update destroy]
  resources :users, only: %i[index show]

  get "/family" => "pages#show", page: "family", as: :family
  get "/pages/:page" => "pages#show", as: :page

  match '/404', to: 'errors#not_found', via: :all
  match '/422', to: 'errors#internal_server_error', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all

  #root "home#index"
  root "pages#index" #  => "pages#show", as: :page

end
