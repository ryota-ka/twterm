require 'twterm/event/base'

module Twterm
  module Event
    module Notification
      # @abstract
      class AbstractNotification < Event::Base
        # @abstract
        # @return [String] notification body
        def body
          raise NotImplementedError, '`body` must be implemented'
        end

        # @return [String] a fallback text
        def fallback
          "#{title}: #{body}"
        end

        # @abstract
        # @return [String] notification title
        def title
          raise NotImplementedError, '`fallback` must be implemented'
        end

        # @return [String, nil] notification URL
        def url
          nil
        end
      end
    end
  end
end
