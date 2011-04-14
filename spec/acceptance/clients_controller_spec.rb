require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "ClientsController" do
  before { host! "http://" + host }
  before { @user = Factory(:user) }
  before { @client = Factory(:client) }
  before { @client_not_owned = Factory(:client, created_from: ANOTHER_USER_URI) }
  before { @scope = Factory(:scope_pizzas_read) }
  before { @scope = Factory(:scope_pizzas_all) }


  context ".index" do
    before { @uri = "/clients" }
    before { @read_client = Factory(:client_read) }

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
        [@client, @read_client].each do |client|
          should_visualize_client(client)
        end
        page.should_not have_content "Not owned client"
      end
    end
  end


  context ".show" do
    before { @uri = "/clients/" + @client.id.as_json }

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
        should_visualize_client(@client)
      end

      scenario "resource not found" do
        @client.destroy
        visit @uri
        page.should have_content "not_found"
        page.should have_content "Resource not found"
      end

      scenario "resource not owned" do
        visit "/clients/" + @client_not_owned.id.as_json
        page.should have_content "not_found"
        page.should have_content "Resource not found"
      end

      scenario "illegal id" do
        visit "/clients/0"
        page.should have_content "not_found"
        page.should have_content "Resource not found"
      end
    end
  end


  context ".create" do
    before { @uri = "/clients/new" }

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
          fill_client()
          click_button 'Create Client'
          @client = Client.last
        end

        scenario "create a resource" do
          should_visualize_client_details(@client)
          page.should have_content "was successfully created"
        end

        scenario "assign an URI to the resource" do
          @client.uri.should == host + "/clients/" + @client.id.as_json
        end
      end

      context "when not valid" do
        scenario "fails" do
          visit @uri
          fill_client("")
          click_button 'Create Client'
          page.should have_content "Name can't be blank"
        end
      end
    end
  end

  context ".update" do
    before { @uri = "/clients/" + @client.id.as_json +  "/edit" }

    context "when not logged in" do
      scenario "is not authorized" do
        visit @uri
        current_url.should == host + "/log_in"
      end
    end

    context "when logged in" do
      before { login(@user) } 

      scenario "update a resource" do
        visit @uri
        fill_client("Example Updated")
        click_button 'Update Client'
        should_visualize_client_details(@client.reload)
        page.should have_content "Example Updated"
        page.should have_content "was successfully updated"
      end

      scenario "resource not found" do
        @client.destroy
        visit @uri
        page.should have_content "not_found"
        page.should have_content "Resource not found"
      end

      scenario "illegal id" do
        visit "/clients/0"
        page.should have_content "not_found"
        page.should have_content "Resource not found"
      end

      context "when not valid" do
        scenario "fails" do
          visit @uri
          fill_client("")
          click_button 'Update Client'
          page.should have_content "Name can't be blank"
        end
      end
    end
  end

  context ".destroy" do
  end

end

