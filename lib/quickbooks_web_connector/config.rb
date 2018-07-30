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

  def self.reset_configuration!
    @config = QuickbooksWebConnector::Configuration.new
    set_default_configuration
  end

  def self.set_default_configuration
    configure do |config|
      config.server_version = '1.0.0'
      config.minimum_web_connector_client_version = nil

      config.parent_controller = 'ApplicationController'

      config.app_name = 'My QBWC App'
      config.app_description = 'My QBWC App Description'
    end
  end

  class Configuration
    include ActiveSupport::Configurable

    config_accessor :server_version
    config_accessor :minimum_web_connector_client_version

    config_accessor :parent_controller

    config_accessor :app_name
    config_accessor :app_description

    def initialize
      config.users = {}
    end

    def users
      config.users
    end

    def user(username, *args)
      username = username.to_s

      config.users[username] = User.new(username, *args)
    end

    def after_authenticate(&block)
      @after_authenticate = block
    end

    def run_after_authenticate
      @after_authenticate.call if @after_authenticate
    end
  end

  set_default_configuration

end
