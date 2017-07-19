require 'concurrent'

require 'twterm/event/screen/resize'
require 'twterm/image'
require 'twterm/subscriber'

module Twterm
  module Tab
    class Base
      include Curses
      include Subscriber

      attr_reader :window
      attr_accessor :title

      def ==(other)
        self.equal?(other)
      end

      def close
        unsubscribe
        window.close
      end

      def find_or_fetch_status(id)
        status = App.instance.status_repository.find(id)

        if status
          Concurrent::Promise.fulfill(status)
        else
          Client.current.show_status(id)
        end
      end

      def find_or_fetch_list(id)
        list = App.instance.list_repository.find(id)

        if list
          Concurrent::Promise.fulfill(list)
        else
          Client.current.list(id)
        end
      end

      def find_or_fetch_user(id)
        user = App.instance.user_repository.find(id)

        if user
          Concurrent::Promise.fulfill(user)
        else
          Client.current.show_user(id)
        end
      end

      def initialize
        @window = stdscr.subwin(stdscr.maxy - 5, stdscr.maxx, 3, 0)

        subscribe(Event::Screen::Resize, :resize)
      end

      def render
        Thread.new do
          refresh_mutex.synchronize do
            window.clear

            # avoid misalignment caused by some multibyte-characters
            window.with_color(:black, :transparent) do
              (0...window.maxy).each do |i|
                window.setpos(i, 0)
                window.addch(' ')
              end
            end

            view.at(1, 2).render
          end if refreshable?
        end
      end

      def respond_to_key(_)
        fail NotImplementedError, 'respond_to_key method must be implemented'
      end

      def title=(title)
        @title = title
        TabManager.instance.refresh_window
      end

      private

      def image
        Image.string('view method is not implemented')
      end

      def refresh_mutex
        @refresh_mutex ||= Mutex.new
      end

      def refreshable?
        !(
          refresh_mutex.locked? ||
            closed? ||
            TabManager.instance.current_tab.object_id != object_id
        )
      end

      def resize(event)
        window.resize(stdscr.maxy - 5, stdscr.maxx)
        window.move(3, 0)
      end

      def view
        View.new(window, image)
      end
    end
  end
end
