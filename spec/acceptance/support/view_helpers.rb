module ViewHelperMethods

  def should_visualize_scope(scope)
    page.should have_content(scope.name)
    page.should have_content(scope.values.join(", "))
  end

  def should_visualize_user(user)
    page.should have_content(user.uri)
    page.should have_content(user.email)
  end

  def fill_scope(name, values)
    fill_in 'Name', with: name
    fill_in 'Values', with: values
  end

end

RSpec.configuration.include ViewHelperMethods, :type => :acceptance

