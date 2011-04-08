require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "ScopesController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { @scope = Factory(:scope, values: WRITE_SCOPE) }

  context ".index" do
    before { @uri = "/scopes" }
    before { @read_scope = Factory(:scope, name: "read", values: READ_SCOPE) }

    context "when not logged in" do
      scenario "is not authorized" do
        visit @uri
        current_url.should == host + "/log_in"
      end
    end

    context "when logged it" do
      before { login(@user) } 

      scenario "view the resources" do
        visit @uri
        [@scope, @read_scope].each do |scope|
          should_visualize_scope(scope)
        end
      end

    end
  end

  context ".show" do
    before { @uri = "/scopes/" + @scope.id.as_json }

    context "when not logged in" do
      scenario "is not authorized" do
        visit @uri
        current_url.should == host + "/log_in"
      end
    end

    context "when logged in" do
      before { login(@user) } 

      scenario "view a resource" do
        visit @uri
        should_visualize_scope(@scope)
      end

      scenario "resource not found" do
      @scope.destroy
      visit @uri
      page.should have_content "not_found"
      page.should have_content "Resource not found"
      end

      scenario "illegal id" do
        visit "/scopes/0"
        page.should have_content "not_found"
        page.should have_content "Resource not found"
      end
    end
  end

  context ".create" do
    before { @uri = "/scopes/new" }

    context "when not logged in" do
      scenario "is not authorized" do
        visit @uri
        current_url.should == host + "/log_in"
      end
    end

    context "when logged in" do
      before { login(@user) } 

      scenario "create a resource" do
        visit @uri
        submit_scope("pizza/read", "pizza/index pizza/show")
        save_and_open_page
        should_visualize_scope(Scope.last)
        page.should have_content "was successfully created"
      end

    end
  end

end
