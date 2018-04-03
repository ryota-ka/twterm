require 'twitter'

require 'twterm/event/abstract_event'

module Twterm
  module Event
    class OpenPhoto < AbstractEvent
      def fields
        { photo: Twitter::Media::Photo }
      end
    end
  end
end
