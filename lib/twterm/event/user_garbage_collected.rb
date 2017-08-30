require 'twterm/event/base'

module Twterm
  module Event
    class UserGarbageCollected < Base
      def fields
        {
          id: Integer
        }
      end
    end
  end
end
