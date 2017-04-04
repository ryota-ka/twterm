require 'twterm/event/base'

module Twterm
  module Event
    module Notification
      class AbstractNotification < Twterm::Event::Base
        attr_reader :time

        def initialize(message)
          super(CGI.unescapeHTML(message))

          @time = Time.now
        end

        def fields
          {
            message: String
          }
        end

        def color
          raise NotImplementedError, 'color method must be overridden'
        end
      end
    end
  end
end
