require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature ".show scope" do
  background { host! "http://" + host}

  context "when not logged in" do
    scenario "is not authorized" do
      visit "/scopes"
      page.driver.status_code.should == 200
      current_url.should == host + "/log_in"
    end
  end

  context "when logged it" do
    before { @user = Factory(:user) }
    before { @scope = Factory(:scope, values: WRITE_SCOPE) }
    before { @read_scope = Factory(:scope, name: "read", values: READ_SCOPE) }
  
    background { login(@user) } 

    scenario "see all scopes" do
      visit "/scopes"
      page.driver.status_code.should == 200
      [@scope, @read_scope].each do |scope|
        page.should have_content(scope.name)
        page.should have_content(scope.values.join(", "))
        page.should have_link("show")
      end
    end

    scenario "see a scope" do
      visit "/scopes/" + @scope.id.as_json
      page.driver.status_code.should == 200
      # TODO refactor in a unique method and put it on a view helper
      page.should have_content(@scope.name)
      page.should have_content(@scope.values.join(", "))
      page.should_not have_link("show")
    end

  end



end
