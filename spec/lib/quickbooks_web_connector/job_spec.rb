require 'spec_helper'

describe QuickbooksWebConnector::Job do

  describe '.queued' do
    it 'returns all queued jobs' do
      expect(described_class.queued.size).to be(0)

      described_class.create(SomeBuilder, SomeHandler, 12)
      described_class.create(SomeBuilder, SomeHandler, 31)

      expect(described_class.queued.size).to eq(2)
    end
  end

  it 'becomes a failure if building the request XML raises an exception' do
    allow(SomeBuilder).to receive(:perform).and_raise(Exception)
    job = described_class.new 'request_builder_class' => 'SomeBuilder'

    expect(job.request_xml).to eq(:failed)

    expect(QuickbooksWebConnector::Failure.count).to be(1)
  end

  it 'becomes a failure if handling the response raises an exception' do
    allow(SomeHandler).to receive(:perform).and_raise(Exception)
    job = described_class.new 'response_handler_class' => 'SomeHandler'

    expect { job.perform }.to_not raise_exception

    expect(QuickbooksWebConnector::Failure.count).to be(1)
  end

end
