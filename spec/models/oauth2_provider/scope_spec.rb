require 'spec_helper'

describe Oauth2Provider::Scope do
  before  { @scope = FactoryGirl.create(:scope, values: ALL_SCOPE) }
  subject { @scope }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:name) }

  it { VALID_URIS.each{|uri| should allow_value(uri).for(:uri) } }
  it { INVALID_URIS.each{|uri| should_not allow_value(uri).for(:uri) } }

  it { should_not allow_mass_assignment_of(:values) }
  it { should_not allow_mass_assignment_of(:uri) }

  its(:values) { should be_a_kind_of Array }
end
