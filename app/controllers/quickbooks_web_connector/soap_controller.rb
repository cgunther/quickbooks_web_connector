module QuickbooksWebConnector
  class SoapController < ApplicationController

    def endpoint
      render xml: SoapWrapper.route(request)
    end

  end
end
