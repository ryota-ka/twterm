require 'twterm/event/base'

module Twterm
  module Event
    class Notification < Base
      attr_reader :time

      def initialize(type, message)
        super(type, CGI.unescapeHTML(message))

        @time = Time.now
      end

      def fields
        {
          type: Symbol,
          message: String
        }
      end

      def color
        case type
        when :error
          [:white, :red]
        when :message
          [:white, :blue]
        else
          [:white, :black]
        end
      end
    end
  end
end
