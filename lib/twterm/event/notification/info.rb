require 'twterm/event/notification/abstract_notification'

module Twterm
  module Event
    module Notification
      class Info < AbstractNotification
        def color
          [:black, :cyan]
        end
      end
    end
  end
end
