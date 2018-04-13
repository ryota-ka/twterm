require 'twitter'

require 'twterm/event/abstract_event'

module Twterm
  module Event
    class OpenPhoto < AbstractEvent
      def fields
        { photo: Addressable::URI }
      end
    end
  end
end
