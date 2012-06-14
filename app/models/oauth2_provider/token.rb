# Access token used from the client to request resource
# owner resouces

module Oauth2Provider
  class Token
    include Mongoid::Document
    include Mongoid::Timestamps

    field :client_uri                           # client identifier (internal)
    field :resource_owner_uri                   # resource owner identifier
    field :token                                # access token
    field :refresh_token                        # refresh token
    field :scope, type: Array                   # scope accessible with token
    field :expire_at, type: Time, default: nil  # token expiration
    field :blocked, type: Time, default: nil    # access token block (if client is blocked)

    before_create :random_token
    before_create :random_refresh_token
    before_create :create_expiration

    validates :client_uri, presence: true, url: true
    validates :resource_owner_uri, presence: true, url: true


    # Block the resource owner delegation to a specific client
    def block!
      self.blocked = Time.now
      self.save
    end

    # Block tokens used from a client
    def self.block_client!(client_uri)
      self.where(client_uri: client_uri).map(&:block!)
    end

    # Block tokens used from a client in behalf of a resource owner
    def self.block_access!(client_uri, resource_owner_uri)
      self.where(client_uri: client_uri, resource_owner_uri: resource_owner_uri).map(&:block!)
    end

    # Check if the status is or is not blocked
    def blocked?
      !self.blocked.nil?
    end

    # Last time the resource owner have used the token
    def last_access
      self.updated_at
    end

    # Token is expired or not
    def expired?
      self.expire_at < Time.now
    end


    private

    def random_token
      self.token = SecureRandom.hex(Oauth2Provider.settings["random_length"])
    end

    def random_refresh_token
      self.refresh_token = SecureRandom.hex(Oauth2Provider.settings["random_length"])
    end

    def create_expiration
      self.expire_at = Chronic.parse("in #{Oauth2Provider.settings["token_expires_in"]} seconds")
    end

  end
end
