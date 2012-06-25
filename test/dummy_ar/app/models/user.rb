class MMSCryptoProvider
  def self.matches?(crypted, *tokens)
    crypted == Digest::SHA1.hexdigest(tokens.reverse.join(''))
  end
end

class User < ActiveRecord::Base
  has_many :client_applications
  has_many :tokens, :class_name => "OauthToken", :order => "authorized_at desc", :include => [:client_application]

  acts_as_authentic do |c|
    c.transition_from_crypto_providers = MMSCryptoProvider
    c.crypto_provider = Authlogic::CryptoProviders::Sha512
  end

  def admin?
    true
  end

end
