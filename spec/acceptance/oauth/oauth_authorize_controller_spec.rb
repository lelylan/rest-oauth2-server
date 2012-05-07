require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "OauthAuthorizeController" do
  before { Client.destroy_all }
  before { OauthAccess.destroy_all }
  before { OauthToken.destroy_all }

  let(:user)        { Factory(:user) }
  let(:client)      { Factory(:client) }
  let(:client_read) { Factory(:client_read) }
  let(:access)      { Factory(:oauth_access) }
  let(:write_scope) { "pizzas" }
  let(:read_scope)  { "pizzas/read" }

  before { @scope = Factory(:scope_pizzas_read) }
  before { @scope = Factory(:scope_pizzas_all) }


  context "Authorization code flow" do
    before { login(user) }

    context "when valid" do
      background do
        visit authorization_grant_page(client, write_scope)
        page.should have_content client.name
      end

      scenario "#grant" do
        click_button("Grant")
        current_url.should == authorization_grant_uri(client)
      end

      scenario "#deny" do
        click_button("Deny")
        current_url.should == authorization_denied_uri(client)
      end
    end

    context "when client is blocked" do
      it "should not load authorization page" do
        client.block!
        visit authorization_grant_page(client, write_scope)
        page.should have_content("Client blocked")
      end
    end

    context "when access is blocked (resource owner block a client)" do
      it "should not load authorization page" do
        access.block!
        visit authorization_grant_page(client, write_scope)
        page.should have_content("Client blocked")
      end
    end

    context "when send an extra state params" do
      background do
        visit(authorization_grant_page(client, write_scope) + "&state=extra")
      end

      scenario "#grant" do
        click_button("Grant")
        current_url.should == authorization_grant_uri(client) + "&state=extra"
      end

      scenario "#deny" do
        click_button("Deny")
        current_url.should == authorization_denied_uri(client) + "&state=extra"
      end
    end

    context "when not valid" do
      scenario "fails with not valid client uri" do
        client.uri = "http://not.existing/"
        visit authorization_grant_page(client, write_scope)
        page.should_not have_content client.name
        page.should have_content("Client not found")
      end

      scenario "fails with not valid scope" do
        visit authorization_grant_page(client_read, write_scope)
        page.should_not have_content client.name
        page.should have_content("Client not authorized")
      end
    end

    context "when not valid scope hacked in HTML page" do
      background do
        visit authorization_grant_page(client_read, read_scope)
        page.should have_content client_read.name
      end

      scenario "fails #grant" do
        page.find("#grant").fill_in("scope", with: "pizzas/create")
        click_button("Grant")
        page.should have_content("Client not authorized")
      end

      scenario "fails #deny" do
        page.find("#deny").fill_in("scope", with: "pizzas/create")
        click_button("Deny")
        page.should have_content("Client not authorized")
      end
    end
  end


  context "Implicit token flow" do
    before { use_javascript }
    before { login(user) }

    context "when valid" do
      background do
        visit implicit_grant_page(client, write_scope)
        page.should have_content client.name
      end

      scenario "#grant" do
        click_button("Grant")
        current_url.should == implicit_grant_uri(client)
      end

      scenario "#deny" do
        click_button("Deny")
        current_url.should == implicit_denied_uri(client)
      end
    end

    context "when client is blocked" do
      it "should not load authorization page" do
        client.block!
        visit implicit_grant_page(client, write_scope)
        page.should have_content("Client blocked")
      end
    end

    context "when access is blocked (resource owner block a client)" do
      it "should not load authorization page" do
        access.block!
        visit implicit_grant_page(client, write_scope)
        page.should have_content("Client blocked")
      end
    end

    context "when send an extra state params" do
      background do
        visit(implicit_grant_page(client, write_scope) + "&state=extra")
      end

      scenario "#grant" do
        click_button("Grant")
        current_url.should == implicit_grant_uri(client) + "&state=extra"
      end

      scenario "#deny" do
        click_button("Deny")
        current_url.should == implicit_denied_uri(client) + "&state=extra"
      end
    end

    context "when not valid" do
      scenario "fails with not valid client uri" do
        client.uri = "http://not.existing/"
        visit implicit_grant_page(client, write_scope)
        page.should_not have_content client.name
        page.should have_content("Client not found")
      end

      scenario "fails with not valid scope" do
        visit implicit_grant_page(client_read, write_scope)
        page.should_not have_content client_read.name
        page.should have_content("Client not authorized")
      end
    end

    after { use_default }
  end


  context "Refresh implicit token flow" do
    before { use_javascript }
    before { @token = Factory(:oauth_token) }
    before { login(user) }

    scenario "should create new token" do
      visit implicit_grant_page(client, write_scope)
      current_url.should == implicit_grant_uri(client)
    end

    context "when send an extra state params" do
      scenario "it should be in the callback" do
        visit(implicit_grant_page(client, write_scope) + "&state=extra")
        current_url.should == implicit_grant_uri(client) + "&state=extra"
      end
    end

    context "when client is blocked" do
      it "should not load authorization page" do
        client.block!
        visit implicit_grant_page(client, write_scope)
        page.should have_content("Client blocked")
      end
    end

    # TODO: in reality it should not authomatically redirect
    # and should show the authorization page (no errors)
    # TODO: miss the scope test
    context "when access is blocked (resource owner block a client)" do
      it "should not load authorization page" do
        access.block!
        visit implicit_grant_page(client, write_scope)
        page.should have_content("Client blocked")
      end
    end

    context "when token is blocked (resource owner log out)" do
      it "should not load authorization page" do
        @token.block!
        visit implicit_grant_page(client, write_scope)
        page.should have_content("Access token blocked from the user")
      end
    end
    
    context "when not valid" do
      scenario "fails with not valid client uri" do
        client.uri = "http://not.existing/"
        visit implicit_grant_page(client, write_scope)
        page.should_not have_content client.name
        page.should have_content("Client not found")
      end

      scenario "fails with not valid scope" do
        visit implicit_grant_page(client_read, write_scope)
        page.should_not have_content client_read.name
        page.should have_content("Client not authorized")
      end
    end
    
    after { use_default }
  end
end
