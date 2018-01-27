module QuickbooksWebConnector
  class QuickbooksWebConnectorController < QuickbooksWebConnector.config.parent_controller.constantize
    skip_before_action :verify_authenticity_token
  end
end
