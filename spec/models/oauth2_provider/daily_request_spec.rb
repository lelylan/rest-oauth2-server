require 'spec_helper'

describe Oauth2Provider::Token do

  let(:access) { FactoryGirl.create(:oauth_access) }
  let(:time) { Chronic.parse("17 august 1982") }
  let(:day_requests) { access.daily_requests_for(time) }

  its(:day)     { day_requests.day.should == "17" }
  its(:month)   { day_requests.month.should == "08" }
  its(:year)    { day_requests.year.should == "1982" }
  its(:time_id) { day_requests.time_id.should == "19820817" }

end
