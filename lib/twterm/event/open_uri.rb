require 'twterm/event/base'

module Twterm
  module Event
    class OpenURI < Base
      def fields
        { uri: Addressable::URI }
      end
    end
  end
end
