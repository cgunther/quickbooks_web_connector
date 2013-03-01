module QuickbooksWebConnector
  class SoapController < QuickbooksWebConnectorController

    def endpoint
      # QWC will perform a GET to check the certificate, so we gotta respond
      render nothing: true and return if request.get?

      response = SoapWrapper.route(request)
      render xml: response, content_type: 'text/xml'
    end

  end
end
