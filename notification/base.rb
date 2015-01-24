module Notification
  module Base
    attr_reader :fg_color, :bg_color

    def initialize(message)
      @message = message
    end

    def show_with_width(width)
      @message.gsub("\n", ' ')
    end

    def fg_color
      fail NotImplementedError, 'fg_color method must be implemented'
    end

    def bg_color
      fail NotImplementedError, 'bg_color method must be implemented'
    end
  end
end
