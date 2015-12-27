require 'twterm/event_dispatcher'
require 'twterm/event/base'

module Twterm
  module Publisher
    def publish(event)
      unless event <= Event::Base
        raise TypeError, 'argument must be a subclass of Twterm::Event::Base'
      end

      EventDispather.instance.dispatch(event)
      event
    end
  end
end
