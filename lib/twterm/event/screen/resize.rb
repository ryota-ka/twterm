require 'twterm/event/base'

module Twterm
  module Event
    module Screen
      class Resize < Base
        def fields
          { lines: Integer, cols: Integer }
        end
      end
    end
  end
end
