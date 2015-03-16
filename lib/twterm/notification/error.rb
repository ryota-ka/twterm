module Twterm
  module Notification
    class Error
      include Base

      def initialize(message)
        super
      end

      def fg_color
        :white
      end

      def bg_color
        :red
      end
    end
  end
end
