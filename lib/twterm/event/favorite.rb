require 'twterm/client'
require 'twterm/event/base'
require 'twterm/user'
require 'twterm/status'

module Twterm
  module Event
    class Favorite < Base
      def fields
        {
          source:              ::Twterm::User,
          target:              ::Twterm::Status,
          authenticating_user: ::Twterm::Client
        }
      end
    end
  end
end
