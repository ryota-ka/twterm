module Twterm
  module History
    class ScreenName
      include Singleton, Base

      def history
        User.all.map(&:screen_name)
      end
    end
  end
end
