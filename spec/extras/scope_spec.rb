require 'spec_helper'

describe "Lelylan::Oauth::Scope" do

  context "when normalizing key" do
    context "#write" do
      let(:scope) { Lelylan::Oauth::Scope.normalize(["write"]) }
      it { scope.should == Lelylan::Oauth::Scope::MATCHES[:write] }
    end

    context "#read" do
      let(:scope) { Lelylan::Oauth::Scope.normalize(["read"]) }
      it { scope.should == Lelylan::Oauth::Scope::MATCHES[:read] }
    end

    context "#type" do
      let(:scope) { Lelylan::Oauth::Scope.normalize(["type"]) }
      it { scope.should == ["type.read", "type.write"] }
    end

    context "#property" do
      let(:scope) { Lelylan::Oauth::Scope.normalize(["property"]) }
      it { scope.should == ["property.read", "property.write"] }
    end

    context "#function" do
      let(:scope) { Lelylan::Oauth::Scope.normalize(["function"]) }
      it { scope.should == ["function.read", "function.write"] }
    end

    context "#status" do
      let(:scope) { Lelylan::Oauth::Scope.normalize(["status"]) }
      it { scope.should == ["status.read", "status.write"] }
    end
  end

  context "when normalizing bases" do
    let(:scope) { Lelylan::Oauth::Scope.normalize(["status.read", "property.write"]) }
    it { scope.should == ["status.read", "property.write"]}
  end

  context "when normalizing not existing keys" do
    let(:scope) { Lelylan::Oauth::Scope.normalize(["status.read", "resource.not_existing"]) }
    it { scope.should == ["status.read"]}
  end

end
