require 'twterm/event/abstract_event'

module Twterm
  module Event
    class UserGarbageCollected < AbstractEvent
      def fields
        {
          id: Integer
        }
      end
    end
  end
end
