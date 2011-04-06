class OauthRefreshToken
  include Mongoid::Document
  include Mongoid::Timestamps

  field :refresh_token
  field :access_token

  validates :access_token, presence: true

  before_create :random_refresh_token

  private
    
    def random_refresh_token
      self.refresh_token = ActiveSupport::SecureRandom.hex(Oauth.settings["random_length"])
    end
  
end
