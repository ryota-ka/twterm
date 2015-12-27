require 'twterm/event/base'

module Twterm
  module Event
    module Status
      class Delete < Base
        def fields
          { status_id: Integer }
        end
      end
    end
  end
end
