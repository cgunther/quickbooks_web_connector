module QuickbooksWebConnector
  class ApplicationController < ActionController::Base
    skip_before_filter :verify_authenticity_token
  end
end
