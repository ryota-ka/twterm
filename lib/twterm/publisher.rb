require 'twterm/event_dispatcher'
require 'twterm/event/base'
require 'twterm/utils'

module Twterm
  module Publisher
    include Utils

    def publish(event)
      check_type Event::Base, event

      EventDispatcher.instance.dispatch(event)
      event
    end
  end
end
