require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "ScopesController.index" do
  before { host! "http://" + host }
  before { @uri = "/scopes" }
  before { @user = Factory(:user) }
  before { @scope = Factory(:scope, values: WRITE_SCOPE) }
  before { @read_scope = Factory(:scope, name: "read", values: READ_SCOPE) }

  context "when not logged in" do
    scenario "is not authorized" do
      visit @uri
      page.driver.status_code.should == 200
      current_url.should == host + "/log_in"
    end
  end

  context "when logged it" do
    before { login(@user) } 

    scenario "view the resources" do
      visit @uri
      [@scope, @read_scope].each do |scope|
        should_visualize_scope(scope)
        page.should have_link("show")
      end
    end

  end
end

feature "ScopesController.show" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { @scope = Factory(:scope, values: WRITE_SCOPE) }
  before { @uri = "/scopes/" + @scope.id.as_json }

  context "when not logged in" do
    scenario "is not authorized" do
      visit @uri
      page.driver.status_code.should == 200
      current_url.should == host + "/log_in"
    end
  end

  context "when logged in" do
    before { login(@user) } 

    scenario "view a resource" do
      visit @uri
      should_visualize_scope(@scope)
      page.should_not have_link("show")
    end

    scenario "resource not found" do
     @scope.destroy
     visit @uri
     page.should have_content "not_found"
     page.should have_content "Resource not found"
    end

    scenario "illegal id" do
      illegal_uri = "/scopes/0"
      visit illegal_uri
      page.should have_content "not_found"
      page.should have_content "Resource not found"
    end
  end
end

feature "ScopeController.create" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { @uri = "/scopes/new" } 
end
