require 'spec_helper'

RSpec.describe QuickbooksWebConnector::QwcController, type: :controller do

  routes { QuickbooksWebConnector::Engine.routes }

  describe 'GET :download' do
    it 'renders the QWC file' do
      QuickbooksWebConnector.config.user 'jane', 'password', '/path/to/company.qbw'

      get :download, params: { username: 'jane', format: :xml }

      expect(response).to be_success
      expect(response.header['Content-Type']).to match(/application\/xml/)
      expect(response.header['Content-Disposition']).to match(/attachment/)
      expect(response.header['Content-Disposition']).to match(/jane\.qwc/)
      expect(response).to render_template(:qwc)
      expect(assigns(:user).username).to eq('jane')
    end

    it 'returns a 404 when no user matches the given username' do
      get :download, params: { username: 'jane', format: :xml }

      expect(response.code).to eq('404')
      expect(response).to_not render_template(:qwc)
    end
  end

end
