require 'spec_helper'
require 'rexml/document'

RSpec.describe 'quickbooks_web_connector/qwc/qwc', type: :view do

  before do
    QuickbooksWebConnector.configure do |config|
      config.app_name = 'My Connector'
      config.app_description = 'Sample description for app'
    end

    assign(:user, QuickbooksWebConnector::User.new('jsmith', 'password', '/path/to/company.qbw', '9ee59974-9edd-444a-9954-a68278b9d958', '2f061062-32f9-454c-8d63-58f161fe5277'))

    render
  end

  let(:root) { REXML::Document.new(rendered).root }

  it 'wraps everything in a QBWCXML element' do
    expect(root.name).to eq('QBWCXML')
  end

  it 'includes the app name along with the username' do
    expect(root.text('AppName')).to eq('My Connector (jsmith)')
  end

  it 'includes the app ID' do
    expect(root.text('AppID')).to be_nil
  end

  it 'includes the endpoint url' do
    expect(root.text('AppURL')).to eq('http://test.host/quickbooks_web_connector/soap')
  end

  it 'includes the description' do
    expect(root.text('AppDescription')).to eq('Sample description for app')
  end

  it 'includes the support url' do
    expect(root.text('AppSupport')).to eq('http://test.host/')
  end

  it 'includes the username' do
    expect(root.text('UserName')).to eq('jsmith')
  end

  it 'includes the owner id' do
    expect(root.text('OwnerID')).to eq('{9ee59974-9edd-444a-9954-a68278b9d958}')
  end

  it 'includes the file id' do
    expect(root.text('FileID')).to eq('{2f061062-32f9-454c-8d63-58f161fe5277}')
  end

  it 'sets the type to QBFS' do
    expect(root.text('QBType')).to eq('QBFS')
  end

end
