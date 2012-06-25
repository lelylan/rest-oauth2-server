TransisAuth::Application.routes.draw do
  mount Oauth2Provider::Engine, at: 'oauth'

  resources :users
  resources :user_sessions

  match '/logout',              :to => 'user_sessions#destroy', :as => :logout
  root :to => 'home#home'
end
