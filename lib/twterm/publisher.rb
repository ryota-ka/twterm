require 'twterm/event_dispatcher'
require 'twterm/event/abstract_event'
require 'twterm/utils'

module Twterm
  module Publisher
    include Utils

    def publish(event)
      check_type Event::AbstractEvent, event

      EventDispatcher.instance.dispatch(event)
      event
    end
  end
end
