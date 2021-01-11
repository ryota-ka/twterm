require 'twterm/event/screen/refresh'
require 'twterm/event/screen/resize'
require 'twterm/key_mapper'
require 'twterm/subscriber'

module Twterm
  class Screen
    include Subscriber

    def initialize(app, client)
      @app, @client = app, client

      @screen = Curses.init_screen
      Curses.noecho
      Curses.raw
      Curses.curs_set(0)
      Curses.stdscr.keypad(true)
      Curses.start_color
      Curses.use_default_colors
      Curses.mousemask(Curses::BUTTON1_CLICKED)

      subscribe(Event::Screen::Refresh) { refresh }
      subscribe(Event::Screen::Resize, :resize)
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
      end
    end

    def refresh
      app.tab_manager.refresh_window
      app.tab_manager.current_tab.render
      MessageWindow.instance.show
    end

    def resize(event)
      return if Curses.closed?

      lines, cols = event.lines, event.cols
      Curses.resizeterm(lines, cols)
      @screen.resize(lines, cols)

      refresh
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
