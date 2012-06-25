Oauth2Provider::Engine.routes.draw do
  namespace :oauth2_provider, path: '' do

    get    "authorize" => "authorize#show", defaults: { format: "html" }
    post   "authorize" => "authorize#create", defaults: { format: "html" }
    delete "authorize" => "authorize#destroy", defaults: { format: "html" }
    delete "token/:id" => "token#destroy", defaults: { format: "json" }
    post   "token" => "token#create", defaults: { format: "json" }

    resources :scopes

    resources :clients do
      put :block, on: :member
      put :unblock, on: :member
    end

    resources :accesses do
      put :block, on: :member
      put :unblock, on: :member
    end

    root :to => "clients#index"
  end

end
