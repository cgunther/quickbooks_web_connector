module QuickbooksWebConnector
  class SoapController < QuickbooksWebConnectorController

    def endpoint
      # QWC will perform a GET to check the certificate, so we gotta respond
      head :no_content and return if request.get?

      response = SoapWrapper.route(request)
      render xml: response, content_type: 'text/xml'
    end

  end
end
