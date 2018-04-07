require 'twterm/event/abstract_event'

module Twterm
  module Event
    module Screen
      class Resize < AbstractEvent
        def fields
          { lines: Integer, cols: Integer }
        end
      end
    end
  end
end
