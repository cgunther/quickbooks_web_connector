require 'spec_helper'

describe QuickbooksWebConnector::SoapController do

  describe 'POST :endpoint' do
    before { post :endpoint, use_route: 'quickbooks_web_connector' }

    it 'responds with success' do
      expect(response).to be_success
    end

    it 'responds as XML' do
      expect(response.header['Content-Type']).to match(/application\/xml/)
    end
  end

end
