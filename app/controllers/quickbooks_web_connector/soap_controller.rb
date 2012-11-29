module QuickbooksWebConnector
  class SoapController < ApplicationController

    def endpoint
      xml = ''
      render xml: xml
    end

  end
end
