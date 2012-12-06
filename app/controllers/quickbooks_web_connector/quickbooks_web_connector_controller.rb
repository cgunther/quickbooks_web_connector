module QuickbooksWebConnector
  class QuickbooksWebConnectorController < QuickbooksWebConnector.config.parent_controller.constantize
    skip_before_filter :verify_authenticity_token
  end
end
