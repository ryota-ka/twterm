module Notification
  class Message
    include Base

    def initialize(message)
      super
    end

    def fg_color
      :white
    end

    def bg_color
      :blue
    end
  end
end
