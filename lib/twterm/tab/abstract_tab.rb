require 'concurrent'

require 'twterm/event/screen/resize'
require 'twterm/image'
require 'twterm/subscriber'

module Twterm
  module Tab
    class AbstractTab
      include Subscriber

      # @return [String]
      attr_reader :title

      # @return [Curses::Window]
      # @todo This can be (and should be) private
      attr_reader :window

      # @param other [Twterm::Tab::AbstractTab]
      #
      # @return [Boolean]
      def ==(other)
        self.equal?(other)
      end

      # @return [void]
      def close
        unsubscribe
        window.close
      end

      # A utility method to find a status by its ID
      #
      # @return [Concurrent::Promise<Twterm::Status>]
      def find_or_fetch_status(id)
        status = app.status_repository.find(id)

        if status
          Concurrent::Promise.fulfill(status)
        else
          client.show_status(id)
        end
      end

      # A utility method to find a list by their ID
      #
      # @return [Concurrent::Promise<Twterm::List>]
      def find_or_fetch_list(id)
        list = app.list_repository.find(id)

        if list
          Concurrent::Promise.fulfill(list)
        else
          client.list(id)
        end
      end

      # A utility method to find a user by their id
      #
      # @return [Concurrent::Promise<Twterm::User>]
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

        @window = Curses.stdscr.subwin(Curses.stdscr.maxy - 3, Curses.stdscr.maxx, 2, 0)

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

      # @return [Twterm::App]
      attr_reader :app

      # @return [Twterm::Client]
      attr_reader :client

      # @return [Twterm::Image]
      def image
        Image.string('view method is not implemented')
      end

      def refresh_mutex
        @refresh_mutex ||= Mutex.new
      end

      # @return [Boolean]
      def refreshable?
        !(
          refresh_mutex.locked? ||
            Curses.closed? ||
            app.tab_manager.current_tab.object_id != object_id
        )
      end

      # @return [void]
      def resize(_event)
        window.resize(Curses.stdscr.maxy - 3, Curses.stdscr.maxx)
        window.move(2, 0)
      end

      # @return [Twterm::View]
      def view
        View.new(window, image)
      end
    end
  end
end
