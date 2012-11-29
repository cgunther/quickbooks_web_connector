require 'spec_helper'

describe QuickbooksWebConnector::SoapController do

  describe 'POST :endpoint' do

    before do
      request.env['CONTENT_TYPE'] = 'text/xml; charset=utf-8'
      request.env['RAW_POST_DATA'] = request_xml
    end

    let(:result) { REXML::Document.new(response.body).root }

    context 'serverVersion' do
      # Request
      let(:request_xml) do
        <<-EOT
          <?xml version=\"1.0\" encoding=\"utf-8\"?>
          <soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\">
            <soap:Body>
              <serverVersion xmlns=\"http://developer.intuit.com/\" />
            </soap:Body>
          </soap:Envelope>
        EOT
      end

      # Response:
      # <env:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
      #    <env:Body>
      #       <n1:serverVersionResponse xmlns:n1="http://developer.intuit.com/">
      #          <n1:serverVersionResult xsi:type="xsd:string">1.2.3</n1:serverVersionResult>
      #       </n1:serverVersionResponse>
      #    </env:Body>
      # </env:Envelope>

      before do
        QuickbooksWebConnector.configure { |c| c.server_version = '1.2.3' }

        post :endpoint, { use_route: 'quickbooks_web_connector' }
      end

      it 'responds with success' do
        expect(response).to be_success
      end

      it 'responds as XML' do
        expect(response.header['Content-Type']).to match(/application\/xml/)
      end

      it 'returns the version' do
        expect(result.text('env:Body/n1:serverVersionResponse/n1:serverVersionResult')).to eq('1.2.3')
      end
    end

    context 'clientVersion' do
      let(:request_xml) do
        <<-EOT
          <?xml version="1.0" encoding="utf-8"?>
          <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
            <soap:Body>
              <clientVersion xmlns="http://developer.intuit.com/">
                <strVersion>2.1.0.30</strVersion>
              </clientVersion>
            </soap:Body>
          </soap:Envelope>
        EOT
      end

      # Response
      # <?xml version="1.0" encoding="utf-8" ?>
      # <env:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
      #   <env:Body>
      #     <n1:clientVersionResponse xmlns:n1="http://developer.intuit.com/"></n1:clientVersionResponse>
      #   </env:Body>
      # </env:Envelope>

      before do
        post :endpoint, { use_route: 'quickbooks_web_connector' }
      end

      it 'responds with success' do
        expect(response).to be_success
      end

      it 'returns the version' do
        expect(result.text('env:Body/n1:clientVersionResponse')).to be_nil
      end
    end

  end

end
