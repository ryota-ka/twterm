require 'twterm/event/abstract_event'

module Twterm
  module Event
    module Message
      class AbstractMessage < AbstractEvent
        attr_reader :time

        def initialize(message)
          super(CGI.unescapeHTML(message))

          @time = Time.now
        end

        def fields
          {
            body: String
          }
        end
      end
    end
  end
end
