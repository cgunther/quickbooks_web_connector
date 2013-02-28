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
        backtrace: Array(exception.backtrace),
      }
      data = QuickbooksWebConnector.encode(data)
      QuickbooksWebConnector.redis.rpush(:failed, data)
    end

  end
end
