$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "quickbooks_web_connector/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "quickbooks_web_connector"
  s.version     = QuickbooksWebConnector::VERSION
  s.authors     = ["Chris Gunther"]
  s.email       = ["chris@room118solutions.com"]
  s.homepage    = "https://github.com/cgunther/quickbooks_web_connector"
  s.summary     = "Rails engine for interfacing with Quickbooks Web Connector"
  s.description = "QuickbooksWebConnector is an engine for sending requests and recieving responses from the Quickbooks Web Connector"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.required_ruby_version = Gem::Requirement.new(">= 2.2.0")

  s.add_dependency "rails", ">= 5.0.0"
  s.add_dependency "soap2r", "~> 1.5.8"
  s.add_dependency "redis-namespace", "~> 1.0"
  s.add_dependency 'logger-application', '~> 0.0.2'

  s.add_development_dependency "sqlite3"
  s.add_development_dependency 'rails-controller-testing'
  s.add_development_dependency 'rspec-rails', '~> 3.1'
end
