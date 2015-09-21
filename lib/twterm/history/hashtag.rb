module Twterm
  module History
    class Hashtag
      include Singleton, Base

      private

      def history_file
        "#{App::DATA_DIR}/hashtags".freeze
      end
    end
  end
end
