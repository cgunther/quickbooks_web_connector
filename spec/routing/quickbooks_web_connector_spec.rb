require 'spec_helper'

describe 'QuickbooksWebConnector routing' do

  before do
    @routes = QuickbooksWebConnector::Engine.routes
  end

  it 'defaults to XML for downloading QWC' do
    expect(get: '/qwc').to route_to(controller: 'quickbooks_web_connector/qwc', action: 'download', format: :xml)
  end

  it 'routes the SOAP endpoint' do
    expect(get: '/soap').to route_to(controller: 'quickbooks_web_connector/soap', action: 'endpoint')
  end

end
