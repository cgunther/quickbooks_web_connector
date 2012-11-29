require 'spec_helper'

describe QuickbooksWebConnector::SoapWrapper::QBWebConnectorSvcSoap do
  let(:servant) { described_class.new }

  describe 'serverVersion' do
    subject(:response) { servant.serverVersion(stub :parameters) }

    before { QuickbooksWebConnector.configure { |c| c.server_version = '1.2.3' } }

    it { should be_a QuickbooksWebConnector::SoapWrapper::ServerVersionResponse }
    its(:serverVersionResult) { should eq '1.2.3' }

    after { QuickbooksWebConnector.configure { |c| c.server_version = '1.0.0' } }
  end

  describe 'clientVersion' do
    subject(:response) { servant.clientVersion(stub :parameters, strVersion: '2.1.0.30') }

    context 'no minimum version set' do
      before { QuickbooksWebConnector.configure { |c| c.minimum_web_connector_client_version = nil } }

      it { should be_a QuickbooksWebConnector::SoapWrapper::ClientVersionResponse }
      its(:clientVersionResult) { should be_nil }

      after { QuickbooksWebConnector.configure { |c| c.minimum_web_connector_client_version = nil } }
    end

    context 'current version passes minimum version check' do
      before { QuickbooksWebConnector.configure { |c| c.minimum_web_connector_client_version = '1.0.0' } }

      it { should be_a QuickbooksWebConnector::SoapWrapper::ClientVersionResponse }
      its(:clientVersionResult) { should be_nil }

      after { QuickbooksWebConnector.configure { |c| c.minimum_web_connector_client_version = nil } }
    end

    context 'current version fails minimum version check' do
      before { QuickbooksWebConnector.configure { |c| c.minimum_web_connector_client_version = '3.0.0' } }

      it { should be_a QuickbooksWebConnector::SoapWrapper::ClientVersionResponse }
      its(:clientVersionResult) { should eq 'E:This version of QuickBooks Web Connector is outdated. Version 3.0.0 or greater is required.' }

      after { QuickbooksWebConnector.configure { |c| c.minimum_web_connector_client_version = nil } }
    end

  end

end
