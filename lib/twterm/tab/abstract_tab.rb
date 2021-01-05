require 'concurrent'

require 'twterm/event/screen/resize'
require 'twterm/image'
require 'twterm/subscriber'

module Twterm
  module Tab
    class AbstractTab
      include Curses
      include Subscriber

      attr_reader :window, :title

      def ==(other)
        self.equal?(other)
      end

      def close
        unsubscribe
        window.close
      end

      def find_or_fetch_status(id)
        status = app.status_repository.find(id)

        if status
          Concurrent::Promise.fulfill(status)
        else
          client.show_status(id)
        end
      end

      def find_or_fetch_list(id)
        list = app.list_repository.find(id)

        if list
          Concurrent::Promise.fulfill(list)
        else
          client.list(id)
        end
      end

      def find_or_fetch_user(id)
        user = app.user_repository.find(id)

        if user
          Concurrent::Promise.fulfill(user)
        else
          client.show_user(id)
        end
      end

      def initialize(app, client)
        @app, @client = app, client

        @window = stdscr.subwin(stdscr.maxy - 3, stdscr.maxx, 2, 0)

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

            view.render
          end if refreshable?
        end
      end

      def respond_to_key(_)
        fail NotImplementedError, 'respond_to_key method must be implemented'
      end

      def title=(title)
        @title = title
        app.tab_manager.refresh_window
      end

      private

      attr_reader :app, :client

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
            app.tab_manager.current_tab.object_id != object_id
        )
      end

      def resize(_event)
        window.resize(stdscr.maxy - 3, stdscr.maxx)
        window.move(2, 0)
      end

      def view
        View.new(window, image)
      end
    end
  end
end
