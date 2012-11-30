require 'redis/namespace'
require 'securerandom'
require 'soap/rpc/standaloneServer'

require 'quickbooks_web_connector/config'

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

end
