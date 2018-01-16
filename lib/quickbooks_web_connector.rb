require 'redis/namespace'
require 'securerandom'
# soap2r 1.5.8 uses Logger::Application, but it was extracted to a gem in Ruby 2.2, so require the gem to maintain compatibility
unless defined?(Logger::Application)
  require 'logger-application'
end
require 'soap/rpc/standaloneServer'

require 'quickbooks_web_connector/config'
require 'quickbooks_web_connector/errors'
require 'quickbooks_web_connector/failure'
require 'quickbooks_web_connector/job'
require 'quickbooks_web_connector/json_coder'
require 'quickbooks_web_connector/user'

require 'quickbooks_web_connector/soap_wrapper/default'
require 'quickbooks_web_connector/soap_wrapper/defaultMappingRegistry'
require 'quickbooks_web_connector/soap_wrapper/defaultServant'
require 'quickbooks_web_connector/soap_wrapper/QBWebConnectorSvc'
require "quickbooks_web_connector/soap_wrapper"

require "quickbooks_web_connector/engine"

module QuickbooksWebConnector
  extend self

  # Accepts:
  #   1. A 'hostname:port' String
  #   2. A 'hostname:port:db' String (to select the Redis db)
  #   3. A 'hostname:port/namespace' String (to set the Redis namespace)
  #   4. A Redis URL String 'redis://host:port'
  #   5. An instance of `Redis`, `Redis::Client`, `Redis::DistRedis`,
  #      or `Redis::Namespace`.
  def redis=(server)
    case server
    when String
      if server['redis://']
        redis = Redis.connect(:url => server, :thread_safe => true)
      else
        server, namespace = server.split('/', 2)
        host, port, db = server.split(':')
        redis = Redis.new(:host => host, :port => port,
          :thread_safe => true, :db => db)
      end
      namespace ||= :qwc

      @redis = Redis::Namespace.new(namespace, :redis => redis)
    when Redis::Namespace
      @redis = server
    else
      @redis = Redis::Namespace.new(:qwc, :redis => server)
    end
  end

  # Returns the current Redis connection. If none has been created, will
  # create a new one.
  def redis
    return @redis if @redis
    self.redis = Redis.respond_to?(:connect) ? Redis.connect(:thread_safe => true) : "localhost:6379"
    self.redis
  end

  # Encapsulation of encode/decode. Overwrite this to use it across QuickbooksWebConnector.
  # This defaults to JSON for backwards compatibilty.
  def coder
    @coder ||= JsonCoder.new
  end
  attr_writer :coder

  #
  # job shortcuts
  #

  # This method can be used to conveniently add a job to the queue.
  # It assumes the class you're passing it is a real Ruby class (not
  # a string or reference).
  def enqueue(request_builder, response_handler, *args)
    if redis.exists(:queue_size)
      redis.incr(:queue_size)
    end

    Job.create(request_builder, response_handler, *args)
  end

  # This method can be used to conveniently remove a job from the queue.
  def dequeue(request_builder, response_handler, *args)
    Job.destroy(request_builder, response_handler, *args)
  end

  # This method will return a `QuickbooksWebConnector::Job` object or
  # a non-true value depending on whether a job can be obtained.
  def reserve
    Job.reserve
  end

  #
  # sync session
  #

  # Store how many jobs we're starting with so that during the sync, we can
  # determine the progress we've made.
  def store_job_count_for_session
    redis.set :queue_size, QuickbooksWebConnector.size
  end

  # Fetch the saved number of jobs for the session
  def job_count_for_session
    redis.get(:queue_size).to_i
  end

  # Clear the temporarily stored count of jobs for the sync session.
  def clear_job_count_for_session
    redis.del :queue_size
  end

  # Figure out how many jobs are left based on the queue size when we started
  # and how many of them are left
  def session_progress
    completed_jobs_count = job_count_for_session - QuickbooksWebConnector.size
    (completed_jobs_count.fdiv(job_count_for_session) * 100).ceil
  end

  #
  # queue manipulation
  #

  # Pushes a job onto the queue. The item should be any JSON-able Ruby object.

  # The `item` is expected to be a hash with the following keys:
  #
  #     xml - The XML to send to Quickbooks as a String.
  #   class - The String name of the response handler.
  #    args - An Array of arguments to pass the handler. Usually passed
  #           via `class.to_class.perform(*args)`.
  #
  # Example
  #
  #   QuickbooksWebConnector.push('xml' => '<some><xml></xml></some>', class' => 'CustomerAddResponseHandler', 'args' => [ 35 ])
  #
  # Returns nothing
  def push(item)
    redis.rpush :queue, encode(item)
  end

  # Pops a job off the queue.
  #
  # Returns a Ruby object.
  def pop
    decode redis.lpop(:queue)
  end

  # Returns an integer representing the size of the queue.
  def size
    redis.llen :queue
  end

  # Returns the next item currently queued, without removing it.
  def peek
    decode redis.lindex :queue, 0
  end

  # Delete any matching items
  def remove(item)
    redis.lrem :queue, 0, encode(item)
  end

  # Does the dirty work of fetching a range of items from a Redis list and
  # converting them into Ruby objects
  def list_range(key, start = 0, stop = -1)
    Array(redis.lrange(key, start, stop)).map do |item|
      decode item
    end
  end

  def encode(object)
    coder.encode object
  end

  def decode(object)
    coder.decode object
  end

end
