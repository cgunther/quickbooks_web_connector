module QuickbooksWebConnector
  class Job

    def initialize(payload)
      @payload = payload
    end

    # Creates a job by placing it on the queue. Expects XML as a string,
    # a string class name, and an optional array of arguments to
    # pass to the class' `perform` method.
    #
    # Raises an exception if no class is given.
    def self.create(request_xml, klass, *args)
      QuickbooksWebConnector.push('request_xml' => request_xml, 'class' => klass.to_s, 'args' => args)
    end

    # Returns an instance of QuickbooksWebConnector::Job
    # if any jobs are available. If not, returns nil.
    def self.reserve
      return unless payload = QuickbooksWebConnector.pop
      new(payload)
    end

    # Return an instance of QuickbooksWebConnector::job if any jobs are
    # available, without removing the job from the queue
    def self.peek
      return unless payload = QuickbooksWebConnector.peek
      new(payload)
    end

    # Returns the request XML from the payload.
    def request_xml
      @payload['request_xml']
    end

    # Returns the actual class constant represented in this job's payload.
    def payload_class
      @payload_class ||= @payload['class'].constantize
    end

    # Returns an array of args represented in this job's payload.
    def args
      @payload['args']
    end

  end
end
