require 'twterm/event/notification/abstract_notification'

module Twterm
  module Event
    module Notification
      class Warning < AbstractNotification
        def color
          [:black, :yellow]
        end
      end
    end
  end
end
