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
    config_accessor :password
    config_accessor :company_file_path

    config_accessor :parent_controller

    config_accessor :app_name
    config_accessor :app_description
  end

  configure do |config|
    config.server_version = '1.0.0'
    config.minimum_web_connector_client_version = nil
    config.username = 'web_connector'
    config.password = 'secret'
    config.company_file_path = ''

    config.parent_controller = 'ApplicationController'

    config.app_name = 'My QBWC App'
    config.app_description = 'My QBWC App Description'
  end

end
