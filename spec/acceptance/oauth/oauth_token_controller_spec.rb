require File.expand_path(File.dirname(__FILE__) + '/../acceptance_helper')

feature "Authorization token flow" do
  before { OauthClient.destroy_all }
  before { OauthAccess.destroy_all }

  let(:user) { Factory(:user) }
  let(:client) { Factory(:oauth_client) }
  let(:authorization) { Factory(:oauth_authorization) }
  let(:access) { Factory(:oauth_access) }

  let(:attributes) { { grant_type: "authorization_code",
                       client_id: client.uri,
                       client_secret: client.secret,
                       code: authorization.code,
                       redirect_uri: client.redirect_uri } }

  scenario "create a token" do
    authorization_token_uri(attributes)
    response_should_have_access_token
    response_should_have_refresh_token
  end

  context "when client is blocked" do
    it "should not load authorization page" do
      client.block!
      authorization_token_uri(attributes)
      page.should have_content "Client blocked"
    end
  end

  context "when access is blocked (resource owner block a client)" do
    it "should not load authorization page" do
      access.block!
      authorization_token_uri(attributes)
      page.should have_content "Client blocked from the user"
    end
  end

  context "when not valid" do
    scenario "fails with not valid code" do
      attributes.merge!(code: "not_existing")
      authorization_token_uri(attributes)
      page.should have_content "Authorization not found"
    end

    scenario "fails with no valid client uri" do
      attributes.merge!(client_id: "not_existing")
      authorization_token_uri(attributes)
      page.should have_content "Client not found"
    end

    scenario "fails when authorization is expired" do
      authorization.expire_at # hack (otherwise do not set the time)
      Delorean.time_travel_to("in 151 seconds")
      authorization_token_uri(attributes)
      page.should have_content "Authorization expired"
      page.should have_content "less than 5 seconds"
    end

  end
end


feature "Password credentials flow" do
  before { OauthClient.destroy_all }
  before { OauthAccess.destroy_all }

  let(:user) { Factory(:user) }
  let(:client) { Factory(:oauth_client) }
  let(:client_read) { Factory(:oauth_client_read) }
  let(:access) { Factory(:oauth_access) }

  let(:attributes) { { grant_type: "password",
                       client_id: client.uri,
                       client_secret: client.secret,
                       username: user.email,
                       password: user.password,
                       scope: "write" } }

  scenario "create a token" do
    password_credentials_token_uri(attributes)
    response_should_have_access_token
    response_should_have_refresh_token
  end

  context "when client is blocked" do
    it "should not load authorization page" do
      client.block!
      password_credentials_token_uri(attributes)
      page.should have_content "Client blocked"
    end
  end

  context "when access is blocked (resource owner block a client)" do
    it "should not load authorization page" do
      access.block!
      password_credentials_token_uri(attributes)
      page.should have_content "Client blocked from the user"
    end
  end

  context "when not valid" do
    scenario "fails with not valid user password" do
      attributes.merge!(password: "not_existing")
      password_credentials_token_uri(attributes)
      page.should have_content "User not found"
    end

    scenario "fails with no valid client uri" do
      attributes.merge!(client_id: "not_existing")
      password_credentials_token_uri(attributes)
      page.should have_content "Client not found"
    end

    scenario "fails with no valid scope authorization" do
      attributes.merge!({client_id: client_read.uri, client_secret: client_read.secret })
      password_credentials_token_uri(attributes)
      page.should have_content "Client not authorized"
    end

    scenario "fails with no scope" do
      attributes.merge!({ scope: nil })
      password_credentials_token_uri(attributes)
      page.should have_content "Client not authorized"
    end
  end

end


feature "Refresh Token" do
  before { OauthClient.destroy_all }
  before { OauthAccess.destroy_all }
  before { OauthRefreshToken.destroy_all }

  let(:user)   { Factory(:user) }
  let(:client) { Factory(:oauth_client) }
  let(:access) { Factory(:oauth_access) }
  let(:token)  { Factory(:oauth_token) }

  let(:refresh_token) { OauthRefreshToken.create(access_token: token.token) }

  let(:attributes) { { grant_type: "refresh_token",
                       refresh_token: refresh_token.refresh_token,
                       client_id: client.uri,
                       client_secret: client.secret } }

  scenario "create an access token" do
    refresh_token_uri(attributes)
    response_should_have_access_token
    response_should_have_refresh_token
  end

  context "when client is blocked" do
    scenario "should not load authorization page" do
      client.block!
      refresh_token_uri(attributes)
      page.should have_content "Client blocked"
    end
  end

  context "when access is blocked (resource owner block a client)" do
    scenario "should not load authorization page" do
      access.block!
      refresh_token_uri(attributes)
      page.should have_content "Client blocked from the user"
    end
  end

  context "when token is blocked (resource owner log out from client)" do
    scenario "should not load authorization page" do
      token.block!
      refresh_token_uri(attributes)
      page.should have_content "Access token authorization expired"
    end
  end


  context "when not valid" do
    scenario "fails with no valid client uri" do
      attributes.merge!(client_id: "not_existing")
      refresh_token_uri(attributes)
      page.should have_content "Client not found"
    end

    scenario "fails with no valid refresh token" do
      attributes.merge!(refresh_token: "not_existing")
      refresh_token_uri(attributes)
      page.should have_content "Refresh token not found"
    end
  end

end
