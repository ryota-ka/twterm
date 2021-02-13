require 'twterm/subscriber'
require 'twterm/event/message/abstract_message'

module Twterm
  class MessageWindow
    include Subscriber

    # @param window [Curses::Window]
    def initialize(window)
      @window = window
      @queue = Queue.new

      subscribe(Event::Message::AbstractMessage) do |e|
        queue(e)
      end

      Thread.new do
        while message = @queue.pop # rubocop:disable Lint/AssignmentInCondition:
          show(message)
          sleep 3
          show
        end
      end
    end

    def show_info(message)
      @queue.push(Event::Message::Info.new(message))
      self
    end

    def show(message = nil)
      loop do
        break unless Curses.closed?
        sleep 0.5
      end

      @window.clear

      if message.is_a?(Event::Message::AbstractMessage)
        fg_color, bg_color =
          case message
          when Event::Message::Error
            [:white, :red]
          when Event::Message::Info
            [:black, :cyan]
          when Event::Message::Success
            [:black, :green]
          when Event::Message::Warning
            [:black, :yellow]
          end

        @window.with_color(fg_color, bg_color) do
          @window.setpos(0, 0)
          @window.addstr(' ' * @window.maxx)
          @window.setpos(0, 1)
          time = message.time.strftime('[%H:%M:%S]')
          body = message.body.gsub("\n", ' ')
          @window.addstr("#{time} #{body}")
        end
      end

      @window.refresh
    end

    private

    def queue(message)
      @queue.push(message)
      self
    end
  end
end
