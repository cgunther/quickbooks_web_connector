require 'active_support/configurable'

module QuickbooksWebConnector
  # Configure global settings for QuickbooksWebConnector
  #   QuickbooksWebConnector.configure do |config|
  #     config.server_version
  #   end
  def self.configure(&block)
    yield @config ||= QuickbooksWebConnector::Configuration.new
  end

  # Global settings for QuickbooksWebConnector
  def self.config
    @config
  end

  class Configuration
    include ActiveSupport::Configurable

    config_accessor :server_version
  end

  configure do |config|
    config.server_version = '1.0.0'
  end

end
