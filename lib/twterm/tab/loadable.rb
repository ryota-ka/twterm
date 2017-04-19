module Twterm
  module Tab
    module Loadable
      def initialize
        super

        @initially_loaded = false
      end

      def initially_loaded?
        @initially_loaded
      end

      def initially_loaded!
        @initially_loaded = true
        render
      end
    end
  end
end
