module QuickbooksWebConnector
  class Job

    attr_accessor :response_xml

    def initialize(payload)
      @payload = payload
    end

    # Creates a job by placing it on the queue. Expects a request builder class
    # name, a response handler class name, and an optional array of arguments to
    # pass to the class' `perform` method.
    #
    # Raises an exception if no class is given.
    def self.create(request_builder, response_handler, *args)
      QuickbooksWebConnector.push(
        'request_builder_class' => request_builder.to_s,
        'response_handler_class' => response_handler.to_s,
        'args' => args
      )
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

    # Find jobs from the queue.
    #
    # Returns the list of jobs queued.
    #
    # This method can be potentially very slow and memory intensive,
    # depending on the size of your queue, as it loads all jobs into
    # a Ruby array.
    def self.queued
      QuickbooksWebConnector.list_range(:queue, 0, -1).map do |item|
        new(item)
      end
    end

    # Attempts to perform the work represented by this job instance.
    # Calls #perform on the class given in the payload with the
    # Quickbooks response and the arguments given in the payload..
    def perform
      begin
        job = response_handler_class

        # Execute the job.
        job.perform(response_xml, *job_args)
      rescue Object => ex
        fail(ex)
      end
    end

    # Returns the request XML from the payload.
    def request_xml
      begin
        request_builder_class.perform(*job_args)
      rescue Object => ex
        fail(ex)
        nil
      end
    end

    # Returns the actual class constant for building the request from the job's payload.
    def request_builder_class
      @request_builder_class ||= @payload['request_builder_class'].constantize
    end

    # Returns the actual class constant represented in this job's payload.
    def response_handler_class
      @response_handler_class ||= @payload['response_handler_class'].constantize
    end

    # Returns an array of args represented in this job's payload.
    def args
      @payload['args']
    end

    def job_args
      args || []
    end

    # Given an exception object, hands off the needed parameters to the Failure
    # module.
    def fail(exception)
      Failure.create(
        payload: @payload,
        exception: exception
      )
    end

  end
end
