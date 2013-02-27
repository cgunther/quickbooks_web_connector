require 'spec_helper'

# require 'quickbooks_web_connector/job'

describe QuickbooksWebConnector::Job do

  it 'becomes a failure if building the request XML raises an exception' do
    SomeBuilder.stub(:perform).and_raise(Exception)
    job = described_class.new 'request_builder_class' => 'SomeBuilder'

    expect { job.request_xml }.to_not raise_exception
  end

end
