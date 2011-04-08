Lelylan::Application.routes.draw do

  namespace :oauth do
    get    "authorization" => "oauth_authorize#show", defaults: { format: "html" }
    post   "authorization" => "oauth_authorize#create", defaults: { format: "html" }
    delete "authorization" => "oauth_authorize#destroy", defaults: { format: "html" }
    post   "token" => "oauth_token#create", defaults: { format: "json" }
  end

  get "log_out" => "sessions#destroy", as: "log_out"
  get "log_in"  => "sessions#new",     as: "log_in"
  get "sign_up" => "users#new",        as: "sign_up"

  resources :users
  resources :sessions
  resources :scopes

  root :to => "users#new"
end
