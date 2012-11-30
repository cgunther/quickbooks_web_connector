module QuickbooksWebConnector
  class EncodeException < StandardError; end
  class DecodeException < StandardError; end

  class JsonCoder
    # Given a Ruby object, returns a string suitable for storage in the
    # queue.
    def encode(object)
      JSON.dump object
    end

    # Given a string, returns a Ruby object.
    def decode(object)
      return unless object

      begin
        JSON.load object
      rescue JSON::ParserError => e
        raise DecodeException, e.message, e.backtrace
      end
    end
  end
end
