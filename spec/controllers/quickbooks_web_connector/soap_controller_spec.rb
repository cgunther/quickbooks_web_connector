require 'spec_helper'

RSpec.describe QuickbooksWebConnector::SoapController, type: :controller do

  routes { QuickbooksWebConnector::Engine.routes }

  # QWC will perform a GET to check the certificate, so we gotta respond
  describe 'GET :endpoint' do
    it 'returns nothing successfully' do
      get :endpoint

      expect(subject.response).to be_success
    end
  end

  describe 'POST :endpoint' do

    def do_post
      post :endpoint
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
        QuickbooksWebConnector.config.server_version = '1.2.3'

        post :endpoint
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
        post :endpoint
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
        QuickbooksWebConnector.config.user 'foo', 'bar', "C:\\path\\to\\company.qbw"
      end

      it 'responds that theres no jobs to work when authenticated without jobs' do
        do_post

        expect(response).to be_success
        expect(result.text('env:Body/n1:authenticateResponse/n1:authenticateResult/n1:string[1]')).to_not be_nil
        expect(result.text('env:Body/n1:authenticateResponse/n1:authenticateResult/n1:string[2]')).to eq('none')
      end

      it 'returns the company_file_path when theres data to send' do
        allow(SomeBuilder).to receive(:perform).with(1).and_return('<some><xml></xml></some>')
        QuickbooksWebConnector.enqueue SomeBuilder, SomeHandler, 1

        do_post

        expect(response).to be_success
        expect(result.text('env:Body/n1:authenticateResponse/n1:authenticateResult/n1:string[1]')).to_not be_nil
        expect(result.text('env:Body/n1:authenticateResponse/n1:authenticateResult/n1:string[2]')).to eq('C:\path\to\company.qbw')
      end
    end

    context 'sendRequestXML' do
      let(:request_xml) do
        <<-EOT
          <?xml version="1.0" encoding="utf-8"?>
          <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
            <soap:Body>
              <sendRequestXML xmlns="http://developer.intuit.com/">
                <ticket>0358d44e-9d87-4d40-8299-3026881951bb</ticket>
                <strHCPResponse></strHCPResponse>
                <strCompanyFileName>C:\\Documents and Settings\\All Users\\Documents\\Intuit\\QuickBooks\\Company Files\\Sample.QBW</strCompanyFileName>
                <qbXMLCountry>US</qbXMLCountry>
                <qbXMLMajorVers>6</qbXMLMajorVers>
                <qbXMLMinorVers>0</qbXMLMinorVers>
              </sendRequestXML>
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
      #     <n1:sendRequestXMLResponse xmlns:n1="http://developer.intuit.com/">
      #       <n1:sendRequestXMLResult xsi:type="xsd:string">&lt;some&gt;&lt;xml&gt;&lt;/xml&gt;&lt;/some&gt;</n1:sendRequestXMLResult>
      #     </n1:sendRequestXMLResponse>
      #   </env:Body>
      # </env:Envelope>

      before do
        allow(SomeBuilder).to receive(:perform).with(1).and_return('<some><xml></xml></some>')
        QuickbooksWebConnector.enqueue SomeBuilder, SomeHandler, 1

        do_post
      end

      it 'responds with success' do
        expect(response).to be_success
      end

      it 'returns the request XML' do
        expect(result.text('env:Body/n1:sendRequestXMLResponse/n1:sendRequestXMLResult')).to eq('<some><xml></xml></some>')
      end
    end

    context 'receiveResponseXML' do
      let(:request_xml) do
        <<-EOT
          <?xml version="1.0" encoding="utf-8"?>
          <soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
            <soap:Body>
              <receiveResponseXML xmlns="http://developer.intuit.com/">
                <ticket>3dde5f3d-dc68-4500-9391-69f75e824330</ticket>
                <response>
                  &lt;?xml version="1.0" ?&gt;
                  &lt;QBXML&gt;
                    &lt;QBXMLMsgsRs&gt;
                      &lt;CustomerAddRs statusCode="0" statusSeverity="Info" statusMessage="Status OK"&gt;
                        &lt;CustomerRet&gt;
                          &lt;ListID&gt;80000006-1354334808&lt;/ListID&gt;
                          &lt;TimeCreated&gt;2012-11-30T23:06:48-05:00&lt;/TimeCreated&gt;
                          &lt;TimeModified&gt;2012-11-30T23:06:48-05:00&lt;/TimeModified&gt;
                          &lt;EditSequence&gt;1354334808&lt;/EditSequence&gt;
                          &lt;Name&gt;Test Inc&lt;/Name&gt;
                          &lt;FullName&gt;Test Inc&lt;/FullName&gt;
                          &lt;IsActive&gt;true&lt;/IsActive&gt;
                          &lt;Sublevel&gt;0&lt;/Sublevel&gt;
                          &lt;Balance&gt;0.00&lt;/Balance&gt;
                          &lt;TotalBalance&gt;0.00&lt;/TotalBalance&gt;
                          &lt;JobStatus&gt;None&lt;/JobStatus&gt;
                        &lt;/CustomerRet&gt;
                      &lt;/CustomerAddRs&gt;
                    &lt;/QBXMLMsgsRs&gt;
                  &lt;/QBXML&gt;
                </response>
                <hresult />
                <message />
              </receiveResponseXML>
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
      #     <n1:receiveResponseXMLResponse xmlns:n1="http://developer.intuit.com/">
      #       <n1:receiveResponseXMLResult xsi:type="xsd:int">100</n1:receiveResponseXMLResult>
      #     </n1:receiveResponseXMLResponse>
      #   </env:Body>
      # </env:Envelope>

      before do
        QuickbooksWebConnector.enqueue '<some><xml></xml></some>', SomeHandler, 1

        do_post
      end

      it 'responds with success' do
        expect(response).to be_success
      end

      it 'returns the percentage done' do
        expect(result.text('env:Body/n1:receiveResponseXMLResponse/n1:receiveResponseXMLResult')).to eq('100')
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
