require 'spec_helper'

RSpec.describe QuickbooksWebConnector::QwcController, type: :controller do

  describe 'GET :download' do
    before { get :download, format: :xml, use_route: 'quickbooks_web_connector' }

    it 'responds with success' do
      expect(response).to be_success
    end

    it 'responds as XML' do
      expect(response.header['Content-Type']).to match(/application\/xml/)
    end

    it 'sends the file as an attachment' do
      expect(response.header['Content-Disposition']).to match(/attachment/)
    end

    it 'names the file' do
      expect(response.header['Content-Disposition']).to match(/qbwc\.qwc/)
    end

    it 'renders the qwc template' do
      assert_template :qwc
    end
  end

end
