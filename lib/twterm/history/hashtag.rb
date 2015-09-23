module Twterm
  module History
    class Hashtag
      include Singleton, Savable

      private

      def file
        "#{App::DATA_DIR}/hashtags".freeze
      end
    end
  end
end
