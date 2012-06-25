Lelylan::Application.routes.draw do
  mount Oauth2Provider::Engine, at: 'oauth'

  get "domains/example/app/callback" => "sessions#new" if Rails.env == 'test'

  get "log_out" => "sessions#destroy", as: "log_out"
  get "log_in"  => "sessions#new",     as: "log_in"

  get "sign_up" => "users#new",        as: "sign_up"
  get "users/show" => "users#show"
  get "users/edit" => "users#edit"

  resources :users
  resources :sessions

  root :to => "sessions#new"

  # sample resources
  resources :pizzas, defaults: { format: "json" }
  resources :pastas, defaults: { format: "json" }

end
