require 'spec_helper'

describe QuickbooksWebConnector::Configuration do
  subject { QuickbooksWebConnector.config }

  describe 'server_version' do

    context 'by default' do
      its(:server_version) { should eq '1.0.0' }
    end

    context 'configured via config block' do
      before { QuickbooksWebConnector.configure { |c| c.server_version = '1.2.3' } }

      its(:server_version) { should eq '1.2.3' }

      after { QuickbooksWebConnector.configure { |c| c.server_version = '1.0.0' } }
    end

  end

end
