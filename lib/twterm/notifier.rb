require 'twterm/subscriber'
require 'twterm/event/favorite'
require 'twterm/event/message/abstract_message'
require 'twterm/event/screen/resize'

module Twterm
  class Notifier
    include Singleton
    include Curses
    include Subscriber

    def initialize
      @window = stdscr.subwin(1, stdscr.maxx, stdscr.maxy - 2, 0)
      @queue = Queue.new

      subscribe(Event::Favorite) do |e|
        next if e.source.id == e.authenticating_user.user_id

        msg = '@%s has favorited your tweet: %s' % [
          e.source.screen_name, e.target.text
        ]
        show_info(msg)
      end

      subscribe(Event::Message::AbstractMessage) do |e|
        queue(e)
      end

      subscribe(Event::Screen::Resize, :resize)

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
        break unless closed?
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

    def resize(_event)
      @window.resize(1, stdscr.maxx)
      @window.move(stdscr.maxy - 2, 0)
    end
  end
end
