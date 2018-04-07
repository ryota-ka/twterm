require 'twterm/event/abstract_event'

module Twterm
  module Event
    module Status
      class Delete < AbstractStatusEvent
        def fields
          { status_id: Integer }
        end
      end
    end
  end
end
