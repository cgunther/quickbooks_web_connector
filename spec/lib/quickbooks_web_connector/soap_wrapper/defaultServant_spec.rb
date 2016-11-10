require 'spec_helper'

describe QuickbooksWebConnector::SoapWrapper::QBWebConnectorSvcSoap do
  let(:servant) { described_class.new }

  describe 'serverVersion' do
    subject(:response) { servant.serverVersion(double(:parameters)) }

    it 'returns returns the configured server_version' do
      QuickbooksWebConnector.config.server_version = '1.2.3'

      expect(response).to be_a(QuickbooksWebConnector::SoapWrapper::ServerVersionResponse)
      expect(response.serverVersionResult).to eq('1.2.3')
    end
  end

  describe 'clientVersion' do
    subject(:response) { servant.clientVersion(double(:parameters, strVersion: '2.1.0.30')) }

    it 'returns nil when no minimum version has been configured' do
      QuickbooksWebConnector.config.minimum_web_connector_client_version = nil

      expect(response).to be_a(QuickbooksWebConnector::SoapWrapper::ClientVersionResponse)
      expect(response.clientVersionResult).to be_nil
    end

    it 'returns nil when the client version passes the minimum configured version' do
      QuickbooksWebConnector.config.minimum_web_connector_client_version = '1.0.0'

      expect(response).to be_a(QuickbooksWebConnector::SoapWrapper::ClientVersionResponse)
      expect(response.clientVersionResult).to be_nil
    end

    it 'returns an error when the client version fails the minimum configured version' do
      QuickbooksWebConnector.config.minimum_web_connector_client_version = '3.0.0'

      expect(response).to be_a(QuickbooksWebConnector::SoapWrapper::ClientVersionResponse)
      expect(response.clientVersionResult).to eq('E:This version of QuickBooks Web Connector is outdated. Version 3.0.0 or greater is required.')
    end
  end

  describe 'authenticate' do
    subject(:response) { servant.authenticate(double(:parameters, strUserName: 'foo', strPassword: 'bar')) }

    context 'unauthorized' do

      it { should be_a QuickbooksWebConnector::SoapWrapper::AuthenticateResponse }

      it 'returns "nvu" with an invalid user' do
        expect(response.authenticateResult[1]).to eq('nvu')
      end
    end

    context 'authorized' do
      before do
        QuickbooksWebConnector.config.user 'foo', 'bar', '/path/to/company.qbw'
      end

      context 'has no data to send' do
        it 'is "none" for having no data' do
          expect(response.authenticateResult[1]).to eq('none')
        end
      end

      context 'has work to do' do
        before do
          QuickbooksWebConnector.enqueue '<some><xml></xml></some>', SomeHandler

          allow(SecureRandom).to receive(:uuid).and_return('71f1f9d9-8012-487c-af33-c84bab4d4ded')
        end

        it { should be_a QuickbooksWebConnector::SoapWrapper::AuthenticateResponse }

        it 'is a token for future requests' do
          expect(response.authenticateResult[0]).to eq('71f1f9d9-8012-487c-af33-c84bab4d4ded')
        end

        it 'returns the path to the company file' do
          expect(response.authenticateResult[1]).to eq('/path/to/company.qbw')
        end

        it 'is nil for delay' do
          expect(response.authenticateResult[2]).to be_nil
        end

        it 'is nil for the new MinimumRunEveryNSeconds' do
          expect(response.authenticateResult[3]).to be_nil
        end

        it 'stores the number of jobs queued for the session for later calculating progress' do
          response

          expect(QuickbooksWebConnector.job_count_for_session).to eq(1)
        end
      end
    end
  end

  describe 'sendRequestXML' do
    subject(:response) { servant.sendRequestXML(double(:parameters)) }

    it 'returns the resulting XML for the next job' do
      allow(SomeBuilder).to receive(:perform).with(1).and_return('<some><xml></xml></some>')
      QuickbooksWebConnector.enqueue SomeBuilder, SomeHandler, 1

      expect(response).to be_a(QuickbooksWebConnector::SoapWrapper::SendRequestXMLResponse)
      expect(response.sendRequestXMLResult).to eq('<some><xml></xml></some>')
    end

    it 'continues onto the next job when the builder errors' do
      allow(SomeBuilder).to receive(:perform).with(1).and_return('<some><xml></xml></some>')
      QuickbooksWebConnector.enqueue SomeBuilderThatErrors, SomeHandler, 1
      QuickbooksWebConnector.enqueue SomeBuilder, SomeHandler, 1

      expect(response).to be_a(QuickbooksWebConnector::SoapWrapper::SendRequestXMLResponse)
      expect(response.sendRequestXMLResult).to eq('<some><xml></xml></some>')
    end
  end

  describe 'receiveResponseXML' do
    subject(:response) { servant.receiveResponseXML(double(:parameters, response: '<response><xml></xml></response>')) }

    before do
      QuickbooksWebConnector.enqueue '<request><xml></xml></request>', SomeHandler, 1
      expect(SomeHandler).to receive(:perform).with('<response><xml></xml></response>', 1)
    end

    it 'returns 100 when no more jobs are left' do
      expect(response).to be_a(QuickbooksWebConnector::SoapWrapper::ReceiveResponseXMLResponse)
      expect(response.receiveResponseXMLResult).to eq(100)
    end

    it 'returns the progress for the session when there are jobs left' do
      QuickbooksWebConnector.enqueue '<other><xml></xml></other>', SomeHandler, 2
      QuickbooksWebConnector.store_job_count_for_session

      expect(response).to be_a(QuickbooksWebConnector::SoapWrapper::ReceiveResponseXMLResponse)
      expect(response.receiveResponseXMLResult).to eq(50)
    end
  end

  describe 'closeConnection' do
    subject(:response) { servant.closeConnection(double(:parameters)) }

    it { should be_a QuickbooksWebConnector::SoapWrapper::CloseConnectionResponse }
  end

end
