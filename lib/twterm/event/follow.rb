require 'twterm/client'
require 'twterm/event/base'
require 'twterm/user'

module Twterm
  module Event
    class Follow < Base
      def fields
        {
          source:              ::Twterm::User,
          target:              ::Twterm::User,
          authenticating_user: ::Twterm::Client
        }
      end
    end
  end
end
