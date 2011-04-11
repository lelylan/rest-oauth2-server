require 'spec_helper'

describe "Oauth" do
  before { Scope.destroy_all }

  before { @scope = Factory(:scope_pizzas_read) }
  before { @scope = Factory(:scope_pizzas_all) }
  before { @scope = Factory(:scope_pastas_read) }
  before { @scope = Factory(:scope_pastas_all) }
  before { @scope = Factory(:scope_read) }
  before { @scope = Factory(:scope_all) }

  context "#normalize_scope" do
    context "single resource" do 
      context "single action" do
        let(:normalized) { Oauth.normalize_scope("pizzas/index") }
        subject { normalized }
        it { should include "pizzas/index" } 
      end

      context "read actions" do
        let(:normalized) { Oauth.normalize_scope("pizzas/read") }
        subject { normalized }

        it { should include "pizzas/index" }
        it { should include "pizzas/show" }
        it { should_not include "pizzas/create"}
      end

      context "read actions and create action" do
        let(:normalized) { Oauth.normalize_scope("pizzas/read pizzas/create") }
        subject { normalized }
  
        it { should include "pizzas/index" }
        it { should include "pizzas/show" }
        it { should include "pizzas/create"}
      end

      context "all rest actions" do
        let(:normalized) { Oauth.normalize_scope("pizzas") }
        subject { normalized }

        it { should include "pizzas/index" }
        it { should include "pizzas/show" } 
        it { should include "pizzas/create" }
        it { should include "pizzas/update" }
        it { should include "pizzas/destroy"}
        it { should_not include "pastas/index" }
        it { should_not include "pizzas" }
      end
    end

    context "all resources" do
      context "single actions" do
        let(:normalized) { Oauth.normalize_scope("pizzas/index pastas/index") }
        subject { normalized }
        it { should include "pizzas/index" }
        it { should_not include "pizzas/show" }
        it { should include "pastas/index" }
        it { should_not include "pastas/show" }
      end
      
      context "read actions" do
        let(:normalized) { Oauth.normalize_scope("read") }
        subject { normalized }

        it { should include "pizzas/index" }
        it { should include "pizzas/show" }
        it { should_not include "pizzas/create"}

        it { should include "pastas/index" }
        it { should include "pastas/show" }
        it { should_not include "pastas/create"}     

        it { should_not include "read" }
        it { should_not include "pizzas/read" }
        it { should_not include "pastas/read" }
      end

      context "all rest actions" do
        let(:normalized) { Oauth.normalize_scope("all") }
        subject { normalized }

        it { should include "pizzas/index" }
        it { should include "pizzas/show" } 
        it { should include "pizzas/create" }
        it { should include "pizzas/update" }
        it { should include "pizzas/destroy"}

        it { should include "pastas/index" }
        it { should include "pastas/show" } 
        it { should include "pastas/create" }
        it { should include "pastas/update" }
        it { should include "pastas/destroy"}

        it { should_not include "all"}
        it { should_not include "pizzas"}
        it { should_not include "pastas"}
        it { should_not include "pizzas/read"}
        it { should_not include "pastas/read"}
      end
    end

  end
end
