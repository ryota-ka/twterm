require 'twterm/subscriber'
require 'twterm/event/favorite'
require 'twterm/event/notification'

module Twterm
  class Notifier
    include Singleton
    include Curses
    include Subscriber

    def initialize
      @window = stdscr.subwin(1, stdscr.maxx, stdscr.maxy - 2, 0)
      @queue = Queue.new

      subscribe(Event::Favorite) do |e|
        break if e.source.id == e.authenticating_user.user_id

        msg = '@%s has favorited your tweet: %s' % [
          e.source.screen_name, e.target.text
        ]
        show_message(msg)
      end

      subscribe(Event::Notification) do |e|
        queue(e)
      end

      Thread.new do
        while notification = @queue.pop
          show(notification)
          sleep 3
          show
        end
      end
    end

    def resize
      @window.resize(1, stdscr.maxx)
      @window.move(stdscr.maxy - 2, 0)
    end

    def show_message(message)
      notification = Event::Notification.new(:message, message)
      @queue.push(notification)
      self
    end

    def show(notification = nil)
      loop do
        break unless closed?
        sleep 0.5
      end

      @window.clear

      if notification.is_a?(Event::Notification)
        fg_color, bg_color = notification.color

        @window.with_color(fg_color, bg_color) do
          @window.setpos(0, 0)
          @window.addstr(' ' * @window.maxx)
          @window.setpos(0, 1)
          time = notification.time.strftime('[%H:%M:%S]')
          message = notification.message.gsub("\n", ' ')
          @window.addstr("#{time} #{message}")
        end
      end

      @window.refresh
    end

    private

    def queue(notification)
      @queue.push(notification)
      self
    end
  end
end
