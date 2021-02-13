require 'twterm/event/screen/refresh'
require 'twterm/key_mapper'
require 'twterm/subscriber'

module Twterm
  class Screen
    include Subscriber

    # @todo Make private
    # @return [Curses::Window]
    attr_reader :tab_manager_window

    # @todo Make private
    # @return [Curses::Window]
    attr_reader :tab_window

    # @todo Make private
    # @return [Curses::Window]
    attr_reader :message_window_window

    # @todo Make private
    # @return [Curses::Window]
    attr_reader :search_query_window_window

    def initialize(app, client)
      @app, @client = app, client

      @stdscr = Curses.init_screen

      width = @stdscr.maxx
      height = @stdscr.maxy

      @tab_manager_window = @stdscr.subwin(1, width, 0, 0)
      @tab_window = @stdscr.subwin(height - 3, width, 2, 0)
      @message_window_window = @stdscr.subwin(1, width, height - 1, 0)
      @search_query_window_window = @stdscr.subwin(1, width, height - 1, 0)

      Curses.noecho
      Curses.raw
      Curses.curs_set(0)
      Curses.stdscr.keypad(true)
      Curses.start_color
      Curses.use_default_colors
      Curses.mousemask(Curses::BUTTON1_CLICKED | 65536 | 2097152)

      subscribe(Event::Screen::Refresh) { refresh }
    end

    def resize(lines, cols)
      return if Curses.closed?

      Curses.resizeterm(lines, cols)
      @stdscr.resize(lines, cols)

      tab_manager_window.move(0, 0)
      tab_manager_window.resize(1, cols)
      tab_manager_window.refresh

      tab_window.move(2, 0)
      tab_window.resize(lines - 3, cols)
      tab_window.refresh

      message_window_window.move(cols - 1, 0)
      message_window_window.resize(1, cols)
      message_window_window.refresh

      search_query_window_window.move(cols - 1, 0)
      search_query_window_window.resize(1, cols)
      search_query_window_window.refresh

      refresh
    end

    def respond_to_key(key)
      k = KeyMapper.instance

      case key
      when k[:status, :compose]
        app.tweetbox.compose
        return
      when k[:app, :quit], 3
        app.quit
      when k[:app, :cheatsheet]
        tab = Tab::KeyAssignmentsCheatsheet.new(app, client)
        app.tab_manager.add_and_show tab
      else
        return false
      end

      true
    end

    def wait
      @thread = Thread.new do
        loop { scan }
      end
      @thread.join
    end

    private

    attr_reader :app, :client

    # @param [Integer, String] key
    def handle_keyboard_event(key)
      return if app.tab_manager.current_tab.respond_to_key(key)
      return if app.tab_manager.respond_to_key(key)
      respond_to_key(key)
    end

    # @param [Curses::MouseEvent] e
    def handle_mouse_event(e)
      x = e.x
      y = e.y

      case e.bstate
      when Curses::BUTTON1_CLICKED
        return app.tab_manager.handle_left_click(x, y) if app.tab_manager.enclose?(x, y)
      when 65536
        scroll_direction = app.preferences[:control, :scroll_direction]

        case scroll_direction
        when 'natural'
          return app.tab_manager.handle_scroll_up(x, y) if app.tab_manager.enclose?(x, y)
        when 'traditional'
          return app.tab_manager.handle_scroll_down(x, y) if app.tab_manager.enclose?(x, y)
        end
      when 2097152
        scroll_direction = app.preferences[:control, :scroll_direction]

        case scroll_direction
        when 'natural'
          return app.tab_manager.handle_scroll_down(x, y) if app.tab_manager.enclose?(x, y)
        when 'traditional'
          return app.tab_manager.handle_scroll_up(x, y) if app.tab_manager.enclose?(x, y)
        end
      end
    end

    def refresh
      app.tab_manager.refresh_window
      app.tab_manager.current_tab.render
      app.message_window.show
    end

    def scan
      app.reset_interruption_handler

      key = Curses.getch

      if key == Curses::Key::MOUSE
        e = Curses.getmouse

        handle_mouse_event(e) unless e.nil?
      else
        handle_keyboard_event(key)
      end
    end
  end
end
