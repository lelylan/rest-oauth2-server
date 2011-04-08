module ViewHelperMethods

  def should_visualize_scope(scope)
    page.should have_content(scope.name)
    page.should have_content(scope.values.join(", "))
  end

end

RSpec.configuration.include ViewHelperMethods, :type => :acceptance

