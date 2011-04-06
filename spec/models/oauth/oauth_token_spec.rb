require 'spec_helper'

describe OauthToken do
  before  { @token = Factory.create(:oauth_token) }
  subject { @token }

  it { should validate_presence_of(:client_uri) }
  it { should allow_value(VALID_URIS).for(:client_uri) }
  it { should validate_presence_of(:resource_owner_uri) }
  it { should allow_value(VALID_URIS).for(:resource_owner_uri) }

  its(:token) { should_not be_nil }
  its(:refresh_token) { should_not be_nil }
  it { should_not be_blocked }

  context "#block!" do
    before { subject.block! }
    it { should be_blocked }
  end

  context ".block_client!" do
    before { @another_client_token = Factory.create(:oauth_token, client_uri: ANOTHER_CLIENT_URI) }
    before { OauthToken.block_client!(CLIENT_URI) }

    it { @token.reload.should be_blocked }
    it { @another_client_token.should_not be_blocked }
  end

  context ".block_access!" do
    before { @another_client_token = Factory.create(:oauth_token, client_uri: ANOTHER_CLIENT_URI)}
    before { @another_owner_token  = Factory.create(:oauth_token, resource_owner_uri: ANOTHER_USER_URI) }
    before { OauthToken.block_access!(CLIENT_URI, USER_URI) }

    it { @token.reload.should be_blocked }
    it { @another_client_token.should_not be_blocked }
    it { @another_owner_token.should_not be_blocked }
  end

  context ".exist" do
    it "should find the token" do
      existing = OauthToken.exist(@token.client_uri, 
                                  @token.resource_owner_uri, 
                                  @token.scope).first
      existing.should_not be_nil
    end
  end


  it "#expired?" do
    subject.should_not be_expired
    Delorean.time_travel_to("in #{Oauth.settings["token_expires_in"]} seconds")
    subject.should be_expired
  end

end
