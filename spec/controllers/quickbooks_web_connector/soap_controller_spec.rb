require 'spec_helper'

describe QuickbooksWebConnector::SoapController do

  describe 'POST :endpoint' do

    def do_post
      post :endpoint, use_route: 'quickbooks_web_connector'
    end

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
        expect(response.header['Content-Type']).to match(/text\/xml/)
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

    context 'authenticate' do
      let(:request_xml) do
        <<-EOT
          <?xml version="1.0" encoding="utf-8"?>
          <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
            <soap:Body>
              <authenticate xmlns="http://developer.intuit.com/">
                <strUserName>foo</strUserName>
                <strPassword>bar</strPassword>
              </authenticate>
            </soap:Body>
          </soap:Envelope>
        EOT
      end

      # Response
      # <?xml version="1.0" encoding="utf-8" ?>
      # <env:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      #     xmlns:xsd="http://www.w3.org/2001/XMLSchema"
      #     xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
      #   <env:Body>
      #     <n1:authenticateResponse xmlns:n1="http://developer.intuit.com/">
      #       <n1:authenticateResult xsi:type="n1:ArrayOfString">
      #         <n1:string xsi:type="xsd:string">5c7e2e0d-8912-4f13-ad60-cac3a3e68bf5</n1:string>
      #         <n1:string xsi:type="xsd:string">none</n1:string>
      #         <n1:string xsi:nil="true"
      #             xsi:type="xsd:nil"></n1:string>
      #         <n1:string xsi:nil="true"
      #             xsi:type="xsd:nil"></n1:string>
      #       </n1:authenticateResult>
      #     </n1:authenticateResponse>
      #   </env:Body>
      # </env:Envelope>

      before do
        QuickbooksWebConnector.configure do |c|
          c.username = 'foo'
          c.password = 'bar'
        end

        do_post
      end

      after do
        QuickbooksWebConnector.configure do |c|
          c.username = 'web_connector'
          c.password = 'secret'
        end
      end

      it 'responds with success' do
        expect(response).to be_success
      end

      it 'returns a token' do
        expect(result.text('env:Body/n1:authenticateResponse/n1:authenticateResult/n1:string[1]')).to_not be_nil
      end

      it 'returns "none" for having no data to send' do
        expect(result.text('env:Body/n1:authenticateResponse/n1:authenticateResult/n1:string[2]')).to eq('none')
      end
    end

    context 'closeConnection' do
      # Request
      let(:request_xml) do
        <<-EOT
          <?xml version="1.0" encoding="utf-8"?>
          <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
            <soap:Body>
              <closeConnection xmlns="http://developer.intuit.com/">
                <ticket>934ea5d9-231e-4426-9ae9-720d1020c472</ticket>
              </closeConnection>
            </soap:Body>
          </soap:Envelope>
        EOT
      end

      # Response
      # <?xml version="1.0" encoding="utf-8" ?>
      # <env:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      #     xmlns:xsd="http://www.w3.org/2001/XMLSchema"
      #     xmlns:env="http://schemas.xmlsoap.org/soap/envelope/">
      #   <env:Body>
      #     <n1:closeConnectionResponse xmlns:n1="http://developer.intuit.com/"></n1:closeConnectionResponse>
      #   </env:Body>
      # </env:Envelope>

      before { do_post }

      it 'responds with success' do
        expect(response).to be_success
      end

      it 'returns the closeConnectionResponse' do
        expect(result.elements['env:Body/n1:closeConnectionResponse']).to_not be_nil
      end
    end

  end

end
