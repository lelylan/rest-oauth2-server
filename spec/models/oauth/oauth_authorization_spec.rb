require 'spec_helper'

describe OauthAuthorization do
  before  { @authorization = Factory.create(:oauth_authorization) }
  subject { @authorization }

  it { should validate_presence_of(:client_uri) }
  it { should allow_value(VALID_URIS).for(:client_uri) }
  it { should validate_presence_of(:resource_owner_uri) }
  it { should allow_value(VALID_URIS).for(:resource_owner_uri) }

  its(:code) { should_not be_nil }
  its(:expire_at) { should_not be_nil }

  it { should_not be_blocked }
  context "#block" do
    before { subject.block! }
    it { should be_blocked }
  end

  context ".block_client!" do
    before { @another_client_authorization = Factory.create(:oauth_authorization, client_uri: ANOTHER_CLIENT_URI) }
    before { OauthAuthorization.block_client!(CLIENT_URI) }

    it { @authorization.reload.should be_blocked }
    it { @another_client_authorization.reload.should_not be_blocked }
  end

  context ".block_access!" do
    before { @another_client_authorization = Factory.create(:oauth_authorization, client_uri: ANOTHER_CLIENT_URI)}
    before { @another_owner_authorization  = Factory.create(:oauth_authorization, resource_owner_uri: ANOTHER_USER_URI) }
    before { OauthAuthorization.block_access!(CLIENT_URI, USER_URI) }

    it { @authorization.reload.should be_blocked }
    it { @another_client_authorization.reload.should_not be_blocked }
    it { @another_owner_authorization.reload.should_not be_blocked }
  end

  it "#expired?" do
    subject.should_not be_expired
    Delorean.time_travel_to("in 151 seconds")
    subject.should be_expired
  end

  it ".where_code_and_client_uri" do
    result = OauthAuthorization.where_code_and_client_uri(subject.code, subject.client_uri).first
    result.should == subject
  end

end
