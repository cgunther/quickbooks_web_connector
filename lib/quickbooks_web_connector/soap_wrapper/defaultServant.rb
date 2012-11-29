module QuickbooksWebConnector
  module SoapWrapper

    class QBWebConnectorSvcSoap
      # SYNOPSIS
      #   serverVersion(parameters)
      #
      # ARGS
      #   parameters      ServerVersion - {http://developer.intuit.com/}serverVersion
      #
      # RETURNS
      #   parameters      ServerVersionResponse - {http://developer.intuit.com/}serverVersionResponse
      #
      def serverVersion(parameters)
        # TODO: Return a real version
        ServerVersionResponse.new(QuickbooksWebConnector.config.server_version)
      end

      # SYNOPSIS
      #   clientVersion(parameters)
      #
      # ARGS
      #   parameters      ClientVersion - {http://developer.intuit.com/}clientVersion
      #
      # RETURNS
      #   parameters      ClientVersionResponse - {http://developer.intuit.com/}clientVersionResponse
      #
      def clientVersion(parameters)
        p [parameters]
        raise NotImplementedError.new
      end

      # SYNOPSIS
      #   authenticate(parameters)
      #
      # ARGS
      #   parameters      Authenticate - {http://developer.intuit.com/}authenticate
      #
      # RETURNS
      #   parameters      AuthenticateResponse - {http://developer.intuit.com/}authenticateResponse
      #
      def authenticate(parameters)
        p [parameters]
        raise NotImplementedError.new
      end

      # SYNOPSIS
      #   sendRequestXML(parameters)
      #
      # ARGS
      #   parameters      SendRequestXML - {http://developer.intuit.com/}sendRequestXML
      #
      # RETURNS
      #   parameters      SendRequestXMLResponse - {http://developer.intuit.com/}sendRequestXMLResponse
      #
      def sendRequestXML(parameters)
        p [parameters]
        raise NotImplementedError.new
      end

      # SYNOPSIS
      #   receiveResponseXML(parameters)
      #
      # ARGS
      #   parameters      ReceiveResponseXML - {http://developer.intuit.com/}receiveResponseXML
      #
      # RETURNS
      #   parameters      ReceiveResponseXMLResponse - {http://developer.intuit.com/}receiveResponseXMLResponse
      #
      def receiveResponseXML(parameters)
        p [parameters]
        raise NotImplementedError.new
      end

      # SYNOPSIS
      #   connectionError(parameters)
      #
      # ARGS
      #   parameters      ConnectionError - {http://developer.intuit.com/}connectionError
      #
      # RETURNS
      #   parameters      ConnectionErrorResponse - {http://developer.intuit.com/}connectionErrorResponse
      #
      def connectionError(parameters)
        p [parameters]
        raise NotImplementedError.new
      end

      # SYNOPSIS
      #   getLastError(parameters)
      #
      # ARGS
      #   parameters      GetLastError - {http://developer.intuit.com/}getLastError
      #
      # RETURNS
      #   parameters      GetLastErrorResponse - {http://developer.intuit.com/}getLastErrorResponse
      #
      def getLastError(parameters)
        p [parameters]
        raise NotImplementedError.new
      end

      # SYNOPSIS
      #   closeConnection(parameters)
      #
      # ARGS
      #   parameters      CloseConnection - {http://developer.intuit.com/}closeConnection
      #
      # RETURNS
      #   parameters      CloseConnectionResponse - {http://developer.intuit.com/}closeConnectionResponse
      #
      def closeConnection(parameters)
        p [parameters]
        raise NotImplementedError.new
      end
    end

  end
end
