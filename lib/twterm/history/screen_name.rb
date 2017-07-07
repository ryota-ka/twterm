module Twterm
  module History
    class ScreenName
      include Singleton, Base

      def history
        App.instance.user_repository.all.map(&:screen_name)
      end
    end
  end
end
