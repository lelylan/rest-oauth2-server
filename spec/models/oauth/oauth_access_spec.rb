require 'spec_helper'

describe OauthAccess do
  before { @access = Factory.create(:oauth_access) }
  subject { @access }

  it { should validate_presence_of(:client_uri) }
  it { should validate_presence_of(:resource_owner_uri) }
  it { should_not be_blocked }

  context "#block!" do
    before { @authorization = Factory.create(:oauth_authorization) }
    before { @another_authorization = Factory.create(:oauth_authorization, client_uri: ANOTHER_CLIENT_URI) }
    before { @token = Factory.create(:oauth_token) }
    before { @another_token = Factory.create(:oauth_token, client_uri: ANOTHER_CLIENT_URI) }

    before { subject.block! }

    it { should be_blocked }
    it { @authorization.reload.should be_blocked }
    it { @another_authorization.reload.should_not be_blocked }
    it { @token.reload.should be_blocked }
    it { @another_token.reload.should_not be_blocked }

    context "#unblock!" do
      before { subject.unblock! }

      it { should_not be_blocked }
      it { @authorization.reload.should be_blocked }
      it { @token.reload.should be_blocked }
    end
  end

  context "when increment access" do
    let(:today)    { Chronic.parse("today at midday") }
    let(:tomorrow) { Chronic.parse("tomorrow at midday") }

    it "should create or increment the daily requests counter" do
      Delorean.time_travel_to today
      3.times { @access.accessed! }
      @access.daily_requests.times.should == 3
      Delorean.time_travel_to tomorrow
      @access.accessed!
      @access.daily_requests.times.should == 1
    end
  end

end
