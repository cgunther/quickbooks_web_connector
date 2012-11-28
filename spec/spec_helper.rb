# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb", __FILE__)

require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support and it's subdirectories
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|

end
