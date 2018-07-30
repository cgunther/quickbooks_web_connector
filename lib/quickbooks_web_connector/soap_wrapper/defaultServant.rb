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
        clientVersionResult = nil

        if QuickbooksWebConnector.config.minimum_web_connector_client_version && QuickbooksWebConnector.config.minimum_web_connector_client_version.to_s > parameters.strVersion
          clientVersionResult = "E:This version of QuickBooks Web Connector is outdated. Version #{QuickbooksWebConnector.config.minimum_web_connector_client_version} or greater is required."
        end

        ClientVersionResponse.new(clientVersionResult)
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
        token = SecureRandom.uuid

        user = QuickbooksWebConnector.config.users[parameters.strUserName]

        result = if user && user.valid_password?(parameters.strPassword)
          QuickbooksWebConnector.config.run_after_authenticate

          if QuickbooksWebConnector.size > 0
            # Store how many jobs are queued so we can track progress later
            QuickbooksWebConnector.store_job_count_for_session

            user.company_file_path
          else
            'none'
          end
        else
          'nvu'
        end

        AuthenticateResponse.new([token, result, nil, nil])
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
        if (job = QuickbooksWebConnector::Job.peek)
          case (request_xml = job.request_xml)
          when :failed
            raise RequestXMLError
          else
            SendRequestXMLResponse.new request_xml
          end
        else
          SendRequestXMLResponse.new nil
        end
      rescue RequestXMLError
        # Remove the job from the queue since it fails to build. The job should have already created a failure.
        QuickbooksWebConnector.pop
        retry
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
        job = QuickbooksWebConnector::Job.reserve

        if parameters.message.present?
          job.fail(ReceiveResponseXMLError.new(parameters.message))
        else
          job.response_xml = parameters.response
          job.perform
        end

        progress = if QuickbooksWebConnector.size == 0
          # We're done
          QuickbooksWebConnector.clear_job_count_for_session
          100
        else
          QuickbooksWebConnector.session_progress
        end

        ReceiveResponseXMLResponse.new(progress)
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
        CloseConnectionResponse.new
      end
    end

  end
end
