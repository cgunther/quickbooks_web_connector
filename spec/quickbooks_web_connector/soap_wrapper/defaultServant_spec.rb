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
end
