module Twterm
  class Screen
    include Singleton
    include Curses

    def initialize
      @screen = init_screen
      noecho
      cbreak
      curs_set(0)
      stdscr.keypad(true)
      start_color
      use_default_colors
    end

    def refresh
      TabManager.instance.refresh_window
      TabManager.instance.current_tab.refresh
      Notifier.instance.show
    end

    def resize
      resizeterm(`tput lines`.to_i, `tput cols`.to_i)
      @screen.resize(`tput lines`.to_i, `tput cols`.to_i)

      TabManager.instance.resize
      TabManager.instance.current_tab.resize
      Notifier.instance.resize
      FilterQueryWindow.instance.resize
      refresh
    end

    def respond_to_key(key)
      case key
      when ?n
        Tweetbox.instance.compose
        return
      when ?Q
        App.instance.quit
      when ??
        tab = Tab::KeyAssignmentsCheatsheet.new
        TabManager.instance.add_and_show tab
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

    def scan
      App.instance.reset_interruption_handler

      key = getch

      return if TabManager.instance.current_tab.respond_to_key(key)
      return if TabManager.instance.respond_to_key(key)
      respond_to_key(key)
    end
  end
end
