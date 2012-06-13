$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "oauth2_provider_engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "oauth2_provider_engine"
  s.version     = Oauth2ProviderEngine::VERSION
  s.authors     = ["Tim Galeckas"]
  s.email       = ["tim@galeckas.com"]
  s.homepage    = "https://github.com/timgaleckas/oauth2_provider_engine"
  s.summary     = "This is a rails 3 engine that provides a source for oauth2 authentication"
  s.description = "Drop this in your app, and client apps can easily use omniauth with oauth2 to use it as a source for authentication"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.5"
  s.add_dependency "jquery-rails"
  s.add_dependency "mongoid"
  s.add_dependency "bson_ext"
  s.add_dependency "validate_url"
  s.add_dependency "chronic"
  s.add_dependency "orm_adapter"

  s.add_development_dependency "sqlite3"
end
