module Oauth2ProviderEngine
  class Schema < ActiveRecord::Migration
    def self.up
      create_table :oauth2_provider_access, :force => true do |t|
        t.string :client_uri
        t.string :resource_owner_uri
        t.datetime :blocked
        t.timestamps
      end
      create_table :oauth2_provider_daily_request, :force => true do |t|
        t.string :time_id
        t.integer :day
        t.integer :month
        t.integer :year
        t.integer :times
        t.references :oauth2_provider_access
        t.timestamps
      end
      create_table :oauth2_provider_authorization, :force => true do |t|
        t.string :client_uri
        t.string :resource_owner_uri
        t.string :code
        t.string :scope_json
        t.datetime :expire_at
        t.datetime :blocked
        t.timestamps
      end
      create_table :oauth2_provider_client, :force => true do |t|
        t.string :uri
        t.string :name
        t.string :created_from
        t.string :secret
        t.string :site_uri
        t.string :redirect_uri
        t.string :scope_json
        t.string :scope_values_json
        t.string :info
        t.integer :granted_times, null: false, default: 0
        t.integer :revoked_times, null: false, default: 0
        t.datetime :blocked
        t.timestamps
      end
      create_table :oauth2_provider_refresh_token, :force => true do |t|
        t.string :refresh_token
        t.string :access_token
        t.timestamps
      end
      create_table :oauth2_provider_scope, :force => true do |t|
        t.string :name
        t.string :uri
        t.string :values_json
        t.timestamps
      end
      create_table :oauth2_provider_token, :force => true do |t|
        t.string :client_uri
        t.string :resource_owner_uri
        t.string :token
        t.string :refresh_token
        t.string :scope_json
        t.datetime :expire_at
        t.datetime :blocked
        t.timestamps
      end
    end

    def self.down
      drop_table :oauth2_provider_access
      drop_table :oauth2_provider_authorization
      drop_table :oauth2_provider_client
      drop_table :oauth2_provider_daily_request
      drop_table :oauth2_provider_refresh_token
      drop_table :oauth2_provider_scope
      drop_table :oauth2_provider_token
    end
  end
end

