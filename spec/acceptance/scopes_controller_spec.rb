require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "ScopesController" do
  before { host! "http://" + host }
  before { @user  = Factory(:user) }
  before { @admin = Factory(:admin) }
  before { @scope = Factory(:scope, values: ALL_SCOPE) }


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
      context "when admin" do
        before { login(@admin) } 

        scenario "view the resources" do
          visit @uri
          should_visualize_scope(@scope)
          should_visualize_scope(@read_scope)
        end
      end

      context "when not admin" do
        before { login(@user) } 
        scenario "do not list all resources" do
          visit @uri
          page.should have_content "Unauthorized access"
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
      context "when admin" do
        before { login(@admin) } 

        scenario "view a resource" do
          visit @uri
          should_visualize_scope(@scope)
        end

        scenario "resource not found" do
          @scope.destroy
          visit @uri
          page.should have_content "Resource not found"
        end

        scenario "illegal id" do
          visit "/scopes/0"
          page.should have_content "Resource not found"
        end
      end

      context "when not admin" do
        before { login(@user) } 
        scenario "do not show a resource" do
          visit @uri
          page.should have_content "Unauthorized access"
        end
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
      context "when admin" do
        before { login(@admin) } 

        context "when valid" do
          before do
            visit @uri
            fill_scope("pizza/read", "pizza/index pizza/show")
            click_button 'Create Scope'
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
            fill_scope("", "")
            click_button 'Create Scope'
            page.should have_content "Name can't be blank"
            page.should have_content "Values can't be blank"
          end
        end
      end

      context "when not admin" do
        before { login(@user) } 
        scenario "do not create a resource" do
          visit @uri
          page.should have_content "Unauthorized access"
        end
      end
    end
  end

  context ".update" do
    before { @uri = "/scopes/" + @scope.id.as_json +  "/edit" }

    context "when not logged in" do
      scenario "is not authorized" do
        visit @uri
        current_url.should == host + "/log_in"
      end
    end

    context "when logged in" do
      context "when admin" do
        before { login(@admin) } 

        scenario "update a resource" do
          visit @uri
          fill_scope("pizza/read/toppings", "pizza/index pizza/show pizza/toppings")
          click_button 'Update Scope'
          page.should have_content("pizza/read/toppings")
          page.should have_content("pizza/toppings")
        end

        scenario "resource not found" do
          @scope.destroy
          visit @uri
          page.should have_content "Resource not found"
        end

        scenario "illegal id" do
          visit "/scopes/0"
          page.should have_content "Resource not found"
        end

        context "when not valid" do
          scenario "fails" do
            visit @uri
            fill_scope("", "")
            click_button 'Update Scope'
            page.should have_content "Name can't be blank"
            page.should have_content "Values can't be blank"
          end
        end

        context "update clients'scopes" do

          before do 
            Scope.destroy_all
            @scope = Factory(:scope_pizzas_all)
            @scope_read = Factory(:scope_pizzas_read)
            @client = Factory(:client)
            @client_read = Factory(:client_read)
          end

          before do
            visit "/scopes/" + @scope_read.id.as_json +  "/edit"
            fill_scope("pizzas/read", "pizzas/show")
            click_button 'Update Scope'
          end

          context "with indirect client" do
            subject { @client.reload.scope_values }
            it { should_not include "pizzas/index" }
            it { should include "pizzas/show" }
            it { should include "pizzas/create" }
            it { should include "pizzas/update" }
            it { should include "pizzas/destroy" }
          end

          context "with direct client" do
            subject { @client_read.reload.scope_values }
            it { should_not include "pizzas/index" }
            it { @client_read.reload.scope_values.should include "pizzas/show" }
          end
        end
      end 

      context "when not admin" do
        before { login(@user) } 
        scenario "do not update a resource" do
          visit @uri
          page.should have_content "Unauthorized access"
        end
      end
    end
  end

  context ".destroy" do
  end

end
