# Authorization grant which represents the authorization
# provided by the resource owner

class OauthAuthorization
  include Mongoid::Document
  include Mongoid::Timestamps

  field :client_uri                           # client identifier
  field :resource_owner_uri                   # resource owner identifier
  field :code                                 # authorization code
  field :scope, type: Array                   # scope accessible with request
  field :expire_at, type: Time                # authorization expiration (security reasons)
  field :blocked, type: Time, default: nil    # authorization block (if client is blocked)

  validates :client_uri, presence: true, url: true
  validates :resource_owner_uri, presence: true, url: true

  before_create :random_code
  before_create :create_expiration

  # Block the authorization (when resource owner blocks a client)
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

  # Check if the authorization is expired
  def expired?
    self.expire_at < Time.now
  end

  # Find the authorization based on the client uri and the
  # authorization code
  class << self
    def where_code_and_client_uri(code, client_id)
      where(code: code).where(client_uri: client_id)
    end
  end


  private

    # random authorization code
    def random_code
      self.code = ActiveSupport::SecureRandom.hex(Oauth.settings["random_length"])
    end

    # expiration time
    def create_expiration
      self.expire_at = Chronic.parse("in #{Oauth.settings["authorization_expires_in"]} seconds")
    end

end
