module ViewHelperMethods

  def should_visualize_scope(scope)
    page.should have_content(scope.name)
    page.should have_content(scope.values.join(", "))
  end

  def submit_scope(name, values)
    fill_in 'Name', with: name
    fill_in 'Values', with: values
    click_button 'Create Scope'
  end

end

RSpec.configuration.include ViewHelperMethods, :type => :acceptance

