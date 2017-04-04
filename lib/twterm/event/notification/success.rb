require 'twterm/event/notification/abstract_notification'

module Twterm
  module Event
    module Notification
      class Success < AbstractNotification
        def color
          [:black, :green]
        end
      end
    end
  end
end
