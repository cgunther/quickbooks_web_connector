require 'spec_helper'

describe QuickbooksWebConnector::SoapController do

  describe 'POST :endpoint' do

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
        request.env['CONTENT_TYPE'] = 'text/xml; charset=utf-8'
        request.env['RAW_POST_DATA'] = request_xml
        post :endpoint, { use_route: 'quickbooks_web_connector' }
      end

      let(:result) { REXML::Document.new(response.body).root }

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

  end

end
