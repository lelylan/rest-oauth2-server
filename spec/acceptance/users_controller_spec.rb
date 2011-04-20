require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "UsersController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { @bob = Factory(:user_bob) }
  before { @admin = Factory(:admin) }


  context ".index" do
    before { @uri = "/users" }

    context "when not logged in" do
      scenario "is not authorized" do
        visit @uri
        current_url.should == host + "/log_in"
      end
    end

    context "when logged in" do
      context "when admin" do
        before { login(@admin) } 
        scenario "list all resources" do
          visit @uri
          [@user, @bob].each do |user|
            should_visualize_user(user)
          end
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
    before { @uri = "/users/" + @user.id.as_json }

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
        should_visualize_user(@user)
      end

      scenario "resource not found" do
        @user.destroy
        visit @uri
        current_url.should == host + "/log_in"
      end

      scenario "access other users profile" do
        login @bob
        visit @uri
        page.should have_content "Resource not found" 
      end

      scenario "access with illegal id" do
        visit "/users/0"
        page.should have_content "Resource not found"
      end
    end
  end


  context ".create" do
    before { @uri = "/sign_up" }

    context "when valid" do
      before do
        visit @uri
        fill_in "Email", with: "new@example.com"
        fill_in "Password", with: "example"
        click_button 'Create User'
      end

      scenario "create a resource" do
        page.should have_content "Signed up"
      end

      scenario "assign an URI to the resource" do
        @user = User.last
        @user.uri.should == host + "/users/" + @user.id.as_json
      end
    end

    context "when not valid" do
      scenario "fails" do
        visit @uri
        fill_in "Email", with: ""
        fill_in "Password", with: ""
        click_button 'Create User'
        page.should have_content "Email can't be blank"
        page.should have_content "Password can't be blank"
      end
    end

    context "when no admin exists" do
      before { @admin.destroy }
      scenario "create admin" do
        visit @uri
        page.should have_content "admin"
        fill_in "Email", with: "new@example.com"
        fill_in "Password", with: "example"
        click_button 'Create User'
        User.last.should be_admin
      end
    end
  end


  context ".update" do
    before { @uri = "/users/" + @user.id.as_json +  "/edit" }

    context "when not logged in" do
      scenario "is not authorized" do
        visit @uri
        current_url.should == host + "/log_in"
      end
    end

    context "when logged in" do
      before { login(@user) } 
      let(:name) { "Alice is my name" }

      scenario "when update fields" do
        visit @uri
        fill_in "Name", with: name
        click_button "Update User"
        page.should have_content(name)
      end

      context "when update the password" do
        let(:new_pass) { "asecurepassword"}

        context "when valid" do
          before do
            visit @uri
            fill_in "Password", with: new_pass
            click_button "Update User"
            click_link "Log out"
          end

          scenario "should log with new pass" do
            login(@user, new_pass)
            page.should have_content "Logged in"
          end

          scenario "should not log with old pass" do
            login(@user)
            page.should_not have_content "Logged in"
            page.should have_content "Invalid email or password"
          end
        end

        scenario "when empty" do
          visit @uri
          fill_in "Password", with: ""
          click_button "Update User"
          click_link "Log out"
          login(@user)
          page.should have_content "Logged in"
        end
      end

      scenario "when resource not found" do
        @user.destroy
        visit @uri
        current_url.should == host + "/log_in"
      end

      scenario "when illegal id" do
        visit "/users/0"
        page.should have_content "Resource not found"
      end

      scenario "when edit other users profile" do
        login @bob
        visit @uri
        page.should have_content "Resource not found" 
      end
    end
  end

  #context ".destroy" do
  #end

end

