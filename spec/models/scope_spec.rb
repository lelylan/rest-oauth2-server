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

  context ".sync_scopes_with_scope" do
    before do 
      Scope.destroy_all
      @scope        = Factory(:scope_pizzas_all)
      @scope_client = Factory(:scope_pizzas_read)
      @scope_client.values = ["pizzas/show"]
      @scope_client.save
      Scope.sync_scopes_with_scope("pizzas/read")
    end

    it "should update all client scope" do
      @scope_client.reload.values.include?(ALL_SCOPE - ["pizzas/index"])
    end
  end
end
