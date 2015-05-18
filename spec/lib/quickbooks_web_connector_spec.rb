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

  it 'can enqueue jobs' do
    expect(described_class.size).to eq(0)
    described_class.enqueue SomeBuilder, SomeHandler, 1, '/tmp'

    job = described_class.reserve

    expect(job).to be_a_kind_of(described_class::Job)
    expect(job.request_builder_class).to eq(SomeBuilder)
    expect(job.response_handler_class).to eq(SomeHandler)
    expect(job.args[0]).to eq 1
    expect(job.args[1]).to eq '/tmp'

    expect(described_class.reserve).to be_nil
  end

  it 'can dequeue jobs' do
    expect(described_class.size).to eq(0)

    described_class.enqueue SomeBuilder, SomeHandler, 1, '/tmp'
    described_class.enqueue SomeBuilder, SomeHandler, 2, '/tmp'

    expect(described_class.size).to eq(2)

    described_class.dequeue SomeBuilder, SomeHandler, 1, '/tmp'

    expect(described_class.size).to eq(1)
  end

  it 'can peek at the queue' do
    described_class.push('name' => 'chris')
    expect(described_class.size).to eq(1)
    expect(described_class.peek).to eq('name' => 'chris')
    expect(described_class.size).to eq(1)
  end

  it 'can calculate the progress of the sync session' do
    described_class.enqueue SomeBuilder, SomeHandler, 1, '/tmp'
    described_class.enqueue SomeBuilder, SomeHandler, 2, '/tmp'
    described_class.enqueue SomeBuilder, SomeHandler, 3, '/tmp'

    described_class.store_job_count_for_session

    expect(described_class.session_progress).to eq(0)

    described_class.reserve

    expect(described_class.session_progress).to eq(34)

    described_class.reserve

    expect(described_class.session_progress).to eq(67)

    described_class.reserve

    expect(described_class.session_progress).to eq(100)
  end

  it 'adapts the progress as jobs are added while the sync is running' do
    described_class.enqueue SomeBuilder, SomeHandler, 1, '/tmp'
    described_class.enqueue SomeBuilder, SomeHandler, 2, '/tmp'
    described_class.enqueue SomeBuilder, SomeHandler, 3, '/tmp'

    described_class.store_job_count_for_session

    described_class.enqueue SomeBuilder, SomeHandler, 4, '/tmp'

    expect(described_class.session_progress).to eq(0) # 0 of 4

    described_class.reserve

    described_class.enqueue SomeBuilder, SomeHandler, 5, '/tmp'

    expect(described_class.session_progress).to eq(20) # 1 of 5

    described_class.reserve

    described_class.enqueue SomeBuilder, SomeHandler, 6, '/tmp'

    expect(described_class.session_progress).to eq(34) # 2 of 6

    described_class.reserve

    described_class.enqueue SomeBuilder, SomeHandler, 7, '/tmp'

    expect(described_class.session_progress).to eq(43) # 3 of 7

    described_class.reserve

    expect(described_class.session_progress).to eq(58) # 4 of 7

    described_class.reserve

    expect(described_class.session_progress).to eq(72) # 5 of 7

    described_class.reserve

    expect(described_class.session_progress).to eq(86) # 6 of 7

    described_class.reserve

    expect(described_class.session_progress).to eq(100) # 7 of 7
  end

end
