class AddOauth2 < ActiveRecord::Migration
  def up
    Oauth2ProviderEngine::Schema.up
  end

  def down
    Oauth2ProviderEngine::Schema.down
  end
end
