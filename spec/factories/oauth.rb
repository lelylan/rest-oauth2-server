require File.expand_path(File.dirname(__FILE__) + '/../support/settings_helper')
include SettingsHelper

FactoryGirl.define do

  factory :user do
     email "alice@example.com"
     password "example"
     uri USER_URI
  end

  factory :oauth_access do
    client_uri CLIENT_URI
    resource_owner_uri USER_URI
  end

  factory :oauth_authorization do
    client_uri CLIENT_URI
    resource_owner_uri USER_URI
    scope Lelylan::Oauth::Scope::SCOPE
  end

  factory :oauth_token do
    client_uri CLIENT_URI
    resource_owner_uri USER_URI
    scope Lelylan::Oauth::Scope::SCOPE
  end

  factory :oauth_client do
    uri CLIENT_URI
    name "the client"
    created_from USER_URI
    redirect_uri REDIRECT_URI
    scope Lelylan::Oauth::Scope::SCOPE
  end

  factory :oauth_client_read, parent: :oauth_client do
    uri ANOTHER_CLIENT_URI
    scope Lelylan::Oauth::Scope::MATCHES[:read]
  end

end


