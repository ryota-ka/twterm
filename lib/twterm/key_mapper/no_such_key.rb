module Twterm
  class KeyMapper
    class NoSuchKey < StandardError
      attr_reader :key

      def initialize(key)
        @key = key
        super(message)
      end

      def message
        "No such key: #{key}"
      end
    end
  end
end
