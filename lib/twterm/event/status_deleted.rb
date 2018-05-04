require 'twterm/event/abstract_event'

module Twterm
  module Event
    class StatusDeleted < AbstractEvent
      def fields
        { status_id: Integer }
      end
    end
  end
end
