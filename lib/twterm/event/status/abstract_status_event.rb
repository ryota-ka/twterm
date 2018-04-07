require 'twterm/status'
require 'twterm/event/abstract_event'

module Twterm
  module Event
    module Status
      class AbstractStatusEvent < AbstractEvent
        def fields
          { status: ::Twterm::Status }
        end
      end
    end
  end
end
