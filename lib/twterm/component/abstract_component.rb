module Twterm
  module Component
    class AbstractComponent
      def image
        raise NotImplementedError, '`image` must be implemented'
      end
    end
  end
end
