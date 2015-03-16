module Twterm
  module Tab
    module AutoReloadable
      def auto_reload(period, &block)
        Thread.new do
          loop do
            sleep period
            block.call
          end
        end
      end
    end
  end
end
