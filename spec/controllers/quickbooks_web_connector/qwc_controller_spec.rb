require 'spec_helper'

RSpec.describe QuickbooksWebConnector::QwcController, type: :controller do

  describe 'GET :download' do
    it 'renders the QWC file' do
      get :download, format: :xml, use_route: 'quickbooks_web_connector'

      expect(response).to be_success
      expect(response.header['Content-Type']).to match(/application\/xml/)
      expect(response.header['Content-Disposition']).to match(/attachment/)
      expect(response.header['Content-Disposition']).to match(/qbwc\.qwc/)
      expect(response).to render_template(:qwc)
    end
  end

end
