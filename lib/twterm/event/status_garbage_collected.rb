require 'twterm/event/base'

module Twterm
  module Event
    class StatusGarbageCollected < Base
      def fields
        {
          id: Integer
        }
      end
    end
  end
end
