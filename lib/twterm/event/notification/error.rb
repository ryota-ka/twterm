require 'twterm/event/notification/abstract_notification'

module Twterm
  module Event
    module Notification
      class Error < AbstractNotification
        def color
          [:white, :red]
        end
      end
    end
  end
end
