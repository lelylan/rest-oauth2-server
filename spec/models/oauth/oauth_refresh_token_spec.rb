require 'spec_helper'

describe OauthRefreshToken do
  before  { @token = Factory(:oauth_token) }
  before  { @refresh_token = OauthRefreshToken.create(access_token: @token.token) }
  subject { @refresh_token }

  it { should validate_presence_of :access_token }

  its(:refresh_token) {should_not be_nil }
end
