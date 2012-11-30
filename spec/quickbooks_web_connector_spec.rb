require 'spec_helper'

describe QuickbooksWebConnector do

  before do
    @original_redis = described_class.redis
  end

  after do
    described_class.redis = @original_redis
  end

  it 'can set a namespace through a url-like string' do
    expect(described_class.redis.namespace).to eq(:qwc)
    described_class.redis = 'localhost:9736/namespace'
    expect(described_class.redis.namespace).to eq('namespace')
  end

  it 'can set a namespace with a Redis::Namespace argument' do
    new_redis = Redis.new(host: 'localhost', port: 9736)
    new_namespace = Redis::Namespace.new('namespace', redis: new_redis)
    described_class.redis = new_namespace
    expect(described_class.redis).to eq(new_namespace)
  end
end
