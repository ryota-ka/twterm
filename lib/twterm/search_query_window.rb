require 'twterm/event/screen/resize'
require 'twterm/subscriber'

module Twterm
  class SearchQueryWindow
    include Curses
    include Singleton
    include Subscriber

    class CancelInput < StandardError; end

    attr_reader :last_query

    def initialize
      @window = stdscr.subwin(1, stdscr.maxx, stdscr.maxy - 1, 0)
      @searching_down = true
      @str = ''
      @last_query = ''

      subscribe(Event::Screen::Resize, :resize)
    end

    def input
      @str = ''
      render_current_string

      Curses.timeout = 10

      chars = []

      loop do
        char = getch

        if char.nil?
          case chars.first
          when 3, 27 # cancel with <C-c> / Esc
            raise CancelInput
          when 4 # cancel with <C-d> when query is empty
            raise CancelInput if @str.empty?
          when 10 # submit with <C-j>
            @str = last_query.to_s if @str.empty?
            break
          when 127 # backspace
            raise CancelInput if @str.empty?

            @str.chop!
            render_current_string
          when 0..31 # rubocop:disable Lint/EmptyWhen
            # ignore control codes (\x00 - \x1f)
          else
            next if chars.empty?
            @str << chars
              .map { |x| x.is_a?(String) ? x.ord : x }
              .pack('c*')
              .force_encoding('utf-8')
            render_current_string
          end

          chars = []
        else
          chars << char
        end
      end

      @last_query = @str unless @str.empty?
      last_query
    rescue CancelInput
      @str = ''
      clear
    ensure
      Curses.timeout = -1
    end

    def clear
      window.clear
      window.refresh
    end

    def render_last_query
      render(last_query) unless last_query.empty?
    end

    def searching_backward!
      @searching_forward = false
    end

    def searching_backward?
      !@searching_forward
    end

    def searching_down!
      @searching_down = true
    end

    def searching_down?
      @searching_down
    end

    def searching_forward!
      @searching_forward = true
    end

    def searching_forward?
      @searching_forward
    end

    def searching_up!
      @searching_down = false
    end

    def searching_up?
      !@searching_down
    end

    private

    attr_reader :window

    def resize(_event)
      window.resize(1, stdscr.maxx)
      window.move(stdscr.maxy - 1, 0)
    end

    def render(str)
      window.clear
      window.setpos(0, 0)
      window.addstr("#{symbol}#{str}")
      window.refresh
    end

    def render_current_string
      render(@str)
    end

    def symbol
      searching_down? ^ searching_forward? ? '?' : '/'
    end
  end
end
