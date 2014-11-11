require 'spec_helper'

describe QuickbooksWebConnector::Configuration do
  subject(:configuration) { QuickbooksWebConnector.config }

  describe 'server_version' do
    it 'returns 1.0.0 by default' do
      expect(configuration.server_version).to eq('1.0.0')
    end

    it 'allows the server_version to be configured' do
      swap QuickbooksWebConnector.config, server_version: '1.2.3' do
        expect(configuration.server_version).to eq('1.2.3')
      end
    end
  end

  describe 'minimum_web_connector_client_version' do
    it 'sets no minimum by default' do
      expect(configuration.minimum_web_connector_client_version).to be_nil
    end

    it 'allows the minimum_web_connector_client_version to be configured' do
      swap QuickbooksWebConnector.config, minimum_web_connector_client_version: '2.1.0.30' do
        expect(configuration.minimum_web_connector_client_version).to eq('2.1.0.30')
      end
    end
  end

  context 'username' do
    it 'uses web_connector by default' do
      expect(configuration.username).to eq('web_connector')
    end

    it 'allows the username to be configured' do
      swap QuickbooksWebConnector.config, username: 'jsmith' do
        expect(configuration.username).to eq('jsmith')
      end
    end
  end

  context 'password' do
    it 'uses secret by default' do
      expect(configuration.password).to eq('secret')
    end

    it 'allows the password to be configured' do
      swap QuickbooksWebConnector.config, password: 'quickbooks' do
        expect(configuration.password).to eq('quickbooks')
      end
    end
  end

  context 'company_file_path' do
    it 'sets no path by default' do
      expect(configuration.company_file_path).to eq('')
    end

    it 'allows the company_file_path to be configured' do
      swap QuickbooksWebConnector.config, company_file_path: '/path/to/company.qbw' do
        expect(configuration.company_file_path).to eq('/path/to/company.qbw')
      end
    end
  end

  describe 'parent_controller' do
    it 'uses ApplicationController by default' do
      expect(configuration.parent_controller).to eq('ApplicationController')
    end

    it 'allows the parent_controller to be configured' do
      swap QuickbooksWebConnector.config, parent_controller: 'MyController' do
        expect(configuration.parent_controller).to eq('MyController')
      end
    end
  end

  describe 'app_name' do
    it 'uses My QBWC App by default' do
      expect(configuration.app_name).to eq('My QBWC App')
    end

    it 'allows the app_name to be configured' do
      swap QuickbooksWebConnector.config, app_name: 'Sample App' do
        expect(configuration.app_name).to eq('Sample App')
      end
    end
  end

  describe 'app_description' do
    it 'sets a default description' do
      expect(configuration.app_description).to eq('My QBWC App Description')
    end

    it 'allows the app_description to be configured' do
      swap QuickbooksWebConnector.config, app_description: 'Sample Description' do
        expect(configuration.app_description).to eq('Sample Description')
      end
    end
  end

end
