require 'twterm/event/notification/abstract_notification'

module Twterm
  module Event
    module Notification
      class ListMemberAdded < AbstractNotification
        # @param [Twterm::List] list
        def initialize(list)
          @list = list
        end

        # @return [String] notification body
        def body
          list.description
        end

        # @return [String] notification title
        def title
          "You've been added to #{list.full_name}"
        end

        # @return [String] notification url
        def url
          list.url
        end

        private

        attr_reader :list
      end
    end
  end
end
