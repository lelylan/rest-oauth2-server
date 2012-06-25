# Application making protected resource requests on behalf of
# the resource owner and with its authorization

if defined?(Mongoid::Document)
  module Oauth2Provider
    class Client
      include Mongoid::Document
      include Mongoid::Timestamps

      field :uri                                       # client identifier (internal)
      field :name                                      # client name
      field :created_from                              # user who created the client
      field :secret                                    # client secret
      field :site_uri                                  # client website
      field :redirect_uri                              # page called after authorization
      field :scope, type: Array, default: []           # raw scope with keywords
      field :scope_values, type: Array, default: []    # scope parsed as array of allowed actions
      field :info                                      # client additional info
      field :granted_times, type: Integer, default: 0  # tokens granted in the authorization step
      field :revoked_times, type: Integer, default: 0  # tokens revoked in the authorization step
      field :blocked, type: Time, default: nil         # blocks any request from the client
    end
  end
elsif defined?(ActiveRecord::Base)
  module Oauth2Provider
    class Client < ActiveRecord::Base
      set_table_name :oauth2_provider_clients
      include Oauth2Provider::Document::ActiveRecordHelp
      before_save :sync_scope_json
      before_save :sync_scope_values_json
    end
  end
elsif defined?(MongoMapper::Document)
  raise NotImplementedError
elsif defined?(DataMapper::Resource)
  raise NotImplementedError
end

module Oauth2Provider
  class Client
    include Document::Base
    attr_accessible :name, :site_uri, :redirect_uri, :info, :scope

    before_create  :random_secret
    before_destroy :clean

    validates :name, presence: true
    validates :uri, presence: true, url: true
    validates :created_from, presence: true, url: true
    validates :redirect_uri, presence: true, url: true


    # Block the client
    def block!
      self.blocked = Time.now
      self.save
      Token.block_client!(self.uri)
      Authorization.block_client!(self.uri)
    end

    # Unblock the client
    def unblock!
      self.blocked = nil
      self.save
    end

    # Check if the status is or is not blocked
    def blocked?
      !self.blocked.nil?
    end

    # Increase the counter of resource owners granting the access
    # to the client
    def granted!
      self.granted_times += 1
      self.save
    end

    # Increase the counter of resource owners revoking the access
    # to the client
    def revoked!
      self.revoked_times += 1
      self.save
    end

    def scope_pretty
      separator = Oauth2Provider.settings["scope_separator"]
      scope.join(separator)
    end

    def scope_values_pretty
      separator = Oauth2Provider.settings["scope_separator"]
      scope_values.join(separator)
    end

    class << self
      # Sync all clients with the correct exploded scope when a
      # scope is modified (changed or removed)
      def sync_clients_with_scope(scope)
        Client.all.each do |client|
          scope_string = client.scope.join(Oauth2Provider.settings["scope_separator"])
          client.scope_values = Oauth2Provider.normalize_scope(scope_string)
          client.save
        end
      end
    end


    private

    # TODO: use atomic updates
    # https://github.com/mongoid/mongoid/commit/aa2c388c71529bf4d987b286acfd861eaac530ce
    def block_tokens!
      Token.to_adapter.find_all(client_uri: uri).map(&:block!)
    end

    def block_authorizations!
      Authorization.to_adapter.find_all(client_uri: uri).map(&:block!)
    end

    def random_secret
      self.secret = SecureRandom.hex(Oauth2Provider.settings["random_length"])
    end

    def clean
      Token.to_adapter.find_all(client_uri: uri).map{|t|Token.to_adapter.destroy(t)}
      Authorization.to_adapter.find_all(client_uri: uri).map{|a|Authorization.to_adapter.destroy(a)}
    end

  end
end
