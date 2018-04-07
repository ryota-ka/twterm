require 'twterm/event/abstract_event'

module Twterm
  module Event
    module Screen
      class Refresh < AbstractEvent
        def fields
          {}
        end
      end
    end
  end
end
