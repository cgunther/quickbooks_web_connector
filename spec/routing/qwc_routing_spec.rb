require 'spec_helper'

describe 'Qwc routing' do

  before do
    @routes = QuickbooksWebConnector::Engine.routes
  end

  it 'defaults to XML' do
    expect(get: '/qwc').to route_to(controller: 'quickbooks_web_connector/qwc', action: 'download', format: :xml)
  end

end
