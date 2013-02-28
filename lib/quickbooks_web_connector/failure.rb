module QuickbooksWebConnector
  class Failure

    # The exception object raised by the failed job
    attr_accessor :exception

    # The payload object associated with the failed job
    attr_accessor :payload

    # Creates a new failure.
    #
    # Expects a hash with the following keys:
    #   :exception - The Exception object
    #   :payload   - The job's payload
    def self.create(options = {})
      new(*options.values_at(:exception, :payload)).save
    end

    def self.count
      QuickbooksWebConnector.redis.llen(:failed).to_i
    end

    def self.all(start = 0, stop = -1)
      QuickbooksWebConnector.list_range(:failed, start, stop)
    end

    def self.find(index)
      QuickbooksWebConnector.list_range(:failed, index, index).first
    end

    def self.requeue(index)
      item = find(index)
      item['retried_at'] = Time.now.rfc2822
      QuickbooksWebConnector.redis.lset(:failed, index, QuickbooksWebConnector.encode(item))
      Job.create(item['payload']['request_builder_class'], item['payload']['response_handler_class'], *item['payload']['args'])
    end

    def self.remove(index)
      id = rand(0xffffff)
      QuickbooksWebConnector.redis.lset(:failed, index, id)
      QuickbooksWebConnector.redis.lrem(:failed, 1, id)
    end

    def initialize(exception, payload)
      @exception = exception
      @payload = payload
    end

    def save
      data = {
        failed_at: Time.now.rfc2822,
        payload: payload,
        exception: exception.class.to_s,
        error: exception.to_s,
        backtrace: filter_backtrace(Array(exception.backtrace)),
      }
      data = QuickbooksWebConnector.encode(data)
      QuickbooksWebConnector.redis.rpush(:failed, data)
    end

    private

      def filter_backtrace(backtrace)
        backtrace.take_while { |item| !item.include?('/lib/quickbooks_web_connector/job.rb') }
      end

  end
end
