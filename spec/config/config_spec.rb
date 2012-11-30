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

  describe 'minimum_web_connector_client_version' do

    context 'by default' do
      its(:minimum_web_connector_client_version) { should be_nil }
    end

    context 'configured via config block' do
      before { QuickbooksWebConnector.configure { |c| c.minimum_web_connector_client_version = '2.1.0.30' } }

      its(:minimum_web_connector_client_version) { should eq '2.1.0.30' }

      after { QuickbooksWebConnector.configure { |c| c.minimum_web_connector_client_version = nil } }
    end

  end

  context 'username' do

    context 'by default' do
      its(:username) { should eq 'web_connector' }
    end

    context 'configured via a config block' do
      before { QuickbooksWebConnector.configure { |c| c.username = 'jsmith' } }

      its(:username) { should eq 'jsmith' }

      after { QuickbooksWebConnector.configure { |c| c.username = 'web_connector' } }
    end
  end

  context 'password' do

    context 'by default' do
      its(:password) { should eq 'secret' }
    end

    context 'configured via a config block' do
      before { QuickbooksWebConnector.configure { |c| c.password = 'quickbooks' } }

      its(:password) { should eq 'quickbooks' }

      after { QuickbooksWebConnector.configure { |c| c.password = 'secret' } }
    end
  end

  context 'company_file_path' do

    context 'by default' do
      its(:company_file_path) { should eq '' }
    end

    context 'configured via a config block' do
      before { QuickbooksWebConnector.configure { |c| c.company_file_path = '/path/to/company.qbw' } }

      its(:company_file_path) { should eq '/path/to/company.qbw' }

      after { QuickbooksWebConnector.configure { |c| c.company_file_path = '' } }
    end
  end

end
