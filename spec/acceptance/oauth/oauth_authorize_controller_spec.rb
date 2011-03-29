require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "Authorization code flow" do
  before { OauthClient.destroy_all }
  before { OauthAccess.destroy_all }

  let(:user) { Factory(:user) }
  let(:client) { Factory(:oauth_client) }
  let(:client_read) { Factory(:oauth_client_read) }
  let(:access) { Factory(:oauth_access) }

  background { login(user) }

  context "when valid" do
    background do
      visit authorization_grant_page(client, "write")
      page.should have_link(client.name, href: client.uri)
    end

    scenario "#grant", do
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
      visit authorization_grant_page(client, "write")
      page.should have_content("Client blocked")
    end
  end

  context "when access is blocked (resource owner block a client)" do
    it "should not load authorization page" do
      access.block!
      visit authorization_grant_page(client, "write")
      page.should have_content("Client blocked")
    end
  end

  context "when send an extra state params" do
    background do
      visit(authorization_grant_page(client, "write") + "&state=extra")
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
      visit authorization_grant_page(client, "write")
      page.should_not have_link(client.name, href: client.uri)
      page.should have_content("Client not found")
    end

    scenario "fails with not valid scope" do
      visit authorization_grant_page(client_read, "write")
      page.should_not have_link(client.name, href: client.uri)
      page.should have_content("Client not authorized")
    end

    scenario "fails with no scope" do
      visit authorization_grant_page(client_read, nil)
      page.should_not have_link(client.name, href: client.uri)
      page.should have_content("Client not authorized")
    end
  end

  context "when not valid scope hacked in HTML page" do
    background do
      visit authorization_grant_page(client_read, "read")
      page.should have_link(client_read.name, href: client_read.uri)
    end

    scenario "fails #grant" do
      page.find("#grant").fill_in("scope", with: "type.write")
      click_button("Grant")
      page.should have_content("Client not authorized")
    end

    scenario "fails #deny" do
      page.find("#deny").fill_in("scope", with: "type.write")
      click_button("Deny")
      page.should have_content("Client not authorized")
    end
  end
end


feature "Implicit token flow" do
  before { OauthClient.destroy_all }
  before { OauthAccess.destroy_all }

  let(:user) { Factory(:user) }
  let(:client) { Factory(:oauth_client) }
  let(:client_read) { Factory(:oauth_client_read) }
  let(:access) { Factory(:oauth_access) }

  before { use_javascript }

  background { login(user) }

  context "when valid" do
    background do
      visit implicit_grant_page(client, "write")
      page.should have_link(client.name, href: client.uri)
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
      visit authorization_grant_page(client, "write")
      page.should have_content("Client blocked")
    end
  end

  context "when access is blocked (resource owner block a client)" do
    it "should not load authorization page" do
      access.block!
      visit authorization_grant_page(client, "write")
      page.should have_content("Client blocked")
    end
  end

  context "when send an extra state params" do
    background do
      visit(implicit_grant_page(client, "write") + "&state=extra")
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
      visit implicit_grant_page(client, "write")
      page.should_not have_link(client.name, href: client.uri)
      page.should have_content("Client not found")
    end

    scenario "fails with not valid scope" do
      visit implicit_grant_page(client_read, "write")
      page.should_not have_link(client_read.name, href: client_read.uri)
      page.should have_content("Client not authorized")
    end
  end

  after { use_default }

end
