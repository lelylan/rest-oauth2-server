require 'spec_helper'

describe Scope do
  before  { @scope = Factory(:scope, values: WRITE_SCOPE) }
  subject { @scope }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:values) }

  it { should allow_value(VALID_URIS).for(:uri) }
  it { should_not allow_value(INVALID_URIS).for(:uri) }

  its(:values) { should be_a_kind_of Array }

  context "when normalize values" do
    before { @values = [{key: "value"}, ["value"]] }
    before { @scope  = Factory(:scope, values: @values) }

    it { @scope.values[0].should == "{:key=>\"value\"}" }
    it { @scope.values[1].should == "[\"value\"]" }
  end
end
