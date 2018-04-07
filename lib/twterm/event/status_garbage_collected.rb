require 'twterm/event/abstract_event'

module Twterm
  module Event
    class StatusGarbageCollected < AbstractEvent
      def fields
        {
          id: Integer
        }
      end
    end
  end
end
