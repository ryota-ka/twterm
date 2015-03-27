module Twterm
  module History
    class ScreenName
      include Singleton, Base

      private

      def history_file
        "#{App::DATA_DIR}/screen_names"
      end
    end
  end
end
