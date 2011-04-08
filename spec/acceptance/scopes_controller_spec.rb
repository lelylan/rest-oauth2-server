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

      context "when valid" do
        before do
          visit @uri
          submit_scope("pizza/read", "pizza/index pizza/show")
          @scope = Scope.last
        end

        scenario "create a resource" do
          should_visualize_scope(@scope)
          page.should have_content "was successfully created"
        end

        scenario "assign an URI to the resource" do
          @scope.uri.should == host + "/scopes/" + @scope.id.as_json
        end
      end

      context "when not valid" do
        scenario "fails" do
          visit @uri
          submit_scope("", "")
          page.should have_content "Name can't be blank"
          page.should have_content "Values can't be blank"
        end
      end

    end
  end

end
