module QuickbooksWebConnector
  class SoapController < ApplicationController

    def endpoint
      response = SoapWrapper.route(request)
      render xml: response, content_type: 'text/xml'
    end

  end
end
