require 'twterm/status'
require 'twterm/event/base'

module Twterm
  module Event
    module Status
      class Base < ::Twterm::Event::Base
        def fields
          { status: ::Twterm::Status }
        end
      end
    end
  end
end
