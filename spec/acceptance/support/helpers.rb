module HelperMethods

  def login(user)
    visit "/log_in"
    fill_in "email", with: user.email
    fill_in "password", with: "example"
    click_button "Log in"
  end


  # Driver switch
  def use_javascript
    Capybara.default_driver = :selenium
    Capybara.javascript_driver = :selenium
  end

  def use_default
    Capybara.default_driver = :rack_test
    Capybara.javascript_driver = :rack_test
  end


  # Authorization page URIs
  def authorization_grant_page(client, scope)
    uri = "/oauth/authorize?response_type=code" + authorization_params(client, scope)
    return URI.escape(uri)
  end

  def implicit_grant_page(client, scope)
    uri = "/oauth/authorize?response_type=token" + authorization_params(client, scope)
    return URI.escape(uri)
  end

  def authorization_params(client, scope)
    uri  = "&scope=#{scope}"
    uri += "&client_id=#{client.uri}"
    uri += "&redirect_uri=#{client.redirect_uri}"
  end


  # Redirect URIs
  def authorization_grant_uri(client)
    authorization = OauthAuthorization.last
    client.redirect_uri + "?code=" + authorization.code
  end

  def implicit_grant_uri(client)
    token = OauthToken.last
    token.token.should_not be_nil
    uri = client.redirect_uri + "#token=" + token.token
  end

  def authorization_denied_uri(client)
    client.redirect_uri + "?access=denied"
  end

  def implicit_denied_uri(client)
    client.redirect_uri + "#access=denied"
  end


  # Token generation (via POST requests)
  def authorization_token_uri(attributes)
    page.driver.post("/oauth/token", attributes.to_json)
  end

  def password_credentials_token_uri(attributes)
    page.driver.post("/oauth/token", attributes.to_json)
  end

  def check_token_response
    token = OauthToken.last
    page.should have_content(token.token)
  end

end

RSpec.configuration.include HelperMethods, :type => :acceptance
