require 'twterm/event/abstract_event'

module Twterm
  module Event
    class OpenURI < AbstractEvent
      def fields
        { uri: Addressable::URI }
      end
    end
  end
end
