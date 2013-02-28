require 'spec_helper'

describe QuickbooksWebConnector::Failure do

  describe '.create' do
    it 'creates a new failure and saves it' do
      failure = stub :failure
      failure.should_receive(:save)
      described_class.should_receive(:new).with(Exception, { foo: 'bar' }).and_return(failure)

      described_class.create(exception: Exception, payload: { foo: 'bar' })
    end
  end

  describe '#save' do
    subject(:failure) { described_class.new(Exception.new('something went wrong'), { foo: 'bar' }) }

    it 'stores the failure with some details in redis' do
      failure.save

      expect(described_class.count).to eq(1)

      item = described_class.all.first
      expect(item['failed_at']).to_not be_nil
      expect(item['payload']).to eq('foo' => 'bar')
      expect(item['exception']).to eq('Exception')
      expect(item['error']).to eq('something went wrong')
      expect(item['backtrace']).to be_an(Array)
    end
  end

end
