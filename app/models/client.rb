# Application making protected resource requests on behalf of
# the resource owner and with its authorization

class Client
  include Mongoid::Document
  include Mongoid::Timestamps
  include Lelylan::Document::Base

  field :uri                                       # client identifier (internal)
  field :name                                      # client name
  field :created_from                              # user who created the client
  field :secret                                    # client secret
  field :site_uri                                  # client website
  field :redirect_uri                              # page called after authorization
  field :scope, type: Array, default: []           # scope asked to resource owner
  field :info                                      # client additional info
  field :granted_times, type: Integer, default: 0  # tokens granted in the authorization step
  field :revoked_times, type: Integer, default: 0  # tokens revoked in the authorization step
  field :blocked, type: Time, default: nil         # blocks any request from the client

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
    OauthToken.block_client!(self.uri)
    OauthAuthorization.block_client!(self.uri)
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
    separator = Oauth.settings["scope_separator"]
    scope.empty? ? "" : scope.join(separator)
  end

  class << self

    # Filter to the client uri (internal identifier) and the
    # redirect uri
    def where_uri(client_uri, redirect_uri)
      where(uri: client_uri).
      where(redirect_uri: redirect_uri)
    end

    # Filter to the client secret and the redirect uri
    def where_secret(secret, client_uri)
      where(secret: secret, uri: client_uri)
    end

    # Filter to the client scope
    def where_scope(scope)
      all_in(scope: scope)
    end

  end


  private

    # TODO: use atomic updates
    # https://github.com/mongoid/mongoid/commit/aa2c388c71529bf4d987b286acfd861eaac530ce
    def block_tokens!
      OauthToken.where(client_uri: uri).map(&:block!)
    end

    def block_authorizations!
      OauthAuthorization.where(client_uri: uri).map(&:block!)
    end

    def random_secret
      self.secret = ActiveSupport::SecureRandom.hex(Oauth.settings["random_length"])
    end

    def clean
      OauthToken.where(client_uri: uri).destroy_all
      OauthAuthorization.where(client_uri: uri).destroy_all
    end

end
