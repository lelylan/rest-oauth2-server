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

    scenario "view resources" do
      visit @uri
      [@scope, @read_scope].each do |scope|
        should_have_scope(scope)
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

    scenario "view resource" do
      visit @uri
      should_have_scope(@scope)
      page.should_not have_link("show")
    end
  end
end
