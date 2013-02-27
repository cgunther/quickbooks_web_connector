require 'spec_helper'

describe QuickbooksWebConnector::Job do

  it 'becomes a failure if building the request XML raises an exception' do
    SomeBuilder.stub(:perform).and_raise(Exception)
    job = described_class.new 'request_builder_class' => 'SomeBuilder'

    expect { job.request_xml }.to_not raise_exception

    expect(QuickbooksWebConnector::Failure.count).to be(1)
  end

  it 'becomes a failure if handling the response raises an exception' do
    SomeHandler.stub(:perform).and_raise(Exception)
    job = described_class.new 'response_handler_class' => 'SomeHandler'

    expect { job.perform }.to_not raise_exception

    expect(QuickbooksWebConnector::Failure.count).to be(1)
  end

end
