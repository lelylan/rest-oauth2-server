# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# Require shared examples ruby files
Dir[Rails.root.join("spec/**/shared/*.rb")].each {|f| require f}

RSpec.configure do |config|

  # Include helpers and global vars
  config.include SettingsHelper

  # Include extra rspec matchers
  config.include Mongoid::Matchers

  # Include time travel methods
  config.include Delorean

  # Mock library
  config.mock_with :rspec

  # User cleanup before each test
  config.before(:each) do
    User.destroy_all
  end

  # Cleaning up MongoDB afterspecs have ben executed
  config.after :suite do
    Mongoid.master.collections.select do |collection|
      collection.name !~ /system/
    end.each(&:drop)
  end

end
