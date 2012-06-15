module ViewHelperMethods

  # Scope
  def should_visualize_scope(scope)
    page.should have_content(scope.name)
    page.should have_content(scope.values_pretty)
  end

  def fill_scope(name, values)
    fill_in 'Name', with: name
    fill_in 'Values', with: values
  end

  # User
  def should_visualize_user(user)
    page.should have_content(user.email)
  end

  # Client
  def should_visualize_client(client)
    page.should have_content(client.name)
  end

  def should_visualize_client_details(client)
    page.should have_content(client.name)
    page.should have_content(client.uri)
    page.should have_content(client.secret)
    page.should have_content(client.site_uri)
    page.should have_content(client.redirect_uri)
    page.should have_content(client.scope_values_pretty)
    page.should have_content("pizzas/create")
    page.should have_content(client.info)
  end

  def fill_client(name = "example")
    fill_in "Name", with: name
    fill_in "Site", with: HOST
    fill_in "Redirect", with: REDIRECT_URI
    fill_in "Scope", with: "pizzas"
    fill_in "Info", with: "This is an example app"
  end

  # bearer token
  def should_not_be_authorized
    page.status_code.should == 401
    page.should have_content "Unauthorized access"
  end

end

RSpec.configuration.include ViewHelperMethods, :type => :acceptance

