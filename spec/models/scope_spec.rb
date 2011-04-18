require 'spec_helper'

describe Scope do
  before  { @scope = Factory(:scope, values: ALL_SCOPE) }
  subject { @scope }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:name) }

  it { should allow_value(VALID_URIS).for(:uri) }
  it { should_not allow_value(INVALID_URIS).for(:uri) }

  it { should_not allow_mass_assignment_of(:values) }
  it { should_not allow_mass_assignment_of(:uri) }

  its(:values) { should be_a_kind_of Array }
end
