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
    config_accessor :minimum_web_connector_client_version
    config_accessor :username
  end

  configure do |config|
    config.server_version = '1.0.0'
    config.minimum_web_connector_client_version = nil
    config.username = 'web_connector'
  end

end
