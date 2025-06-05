Rails.application.routes.draw do
  devise_for :users,
             path: "",
             path_names: {
               sign_in: "login",
               sign_out: "logout",
               registration: "signup"
             },
             defaults: { format: :json },
             controllers: {
               sessions: "users/sessions",
               registrations: "users/registrations"
             }

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :market_place, path: "", defaults: { format: :json } do
    resources :products, only: [ :index, :show ]
    resource :cart, only: [ :show ]
    resources :cart_items, param: :product_id, only: [ :create, :update, :destroy ]
    resources :orders, only: [ :index, :create, :show, :update ] do
      member do
        patch :cancel
      end
    end
  end

  namespace :admin do
    resources :products do
      member do
        patch :toggle_status
      end
    end
    resources :orders, only: [ :index, :show, :update ]
  end
end
