require 'twterm/event/base'

module Twterm
  module Event
    module Message
      class AbstractMessage < Twterm::Event::Base
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
