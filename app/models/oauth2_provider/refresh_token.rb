if defined?(Mongoid::Document)
  module Oauth2Provider
    class RefreshToken
      include Mongoid::Document
      include Mongoid::Timestamps

      field :refresh_token
      field :access_token
    end
  end
elsif defined?(ActiveRecord::Base)
  module Oauth2Provider
    class RefreshToken < ActiveRecord::Base
    end
  end
elsif defined?(MongoMapper::Document)
  raise NotImplementedError
elsif defined?(DataMapper::Resource)
  raise NotImplementedError
end

module Oauth2Provider
  class RefreshToken
    validates :access_token, presence: true

    before_create :random_refresh_token

    private

    def random_refresh_token
      self.refresh_token = SecureRandom.hex(Oauth2Provider.settings["random_length"])
    end

  end
end
