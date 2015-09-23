module Twterm
  module History
    module Base
      attr_reader :history

      def initialize
        @history = []
      end

      def add(item)
        @history << item
      end

      private

      def file
        fail NotImplementedError, 'file method must be implemented'
      end
    end
  end
end
