require 'readline'
require 'singleton'
require 'bundler'
Bundler.require

class Tweetbox
  include Singleton
  include Readline
  include Curses

  def initialize
    @window = stdscr.subwin(3, 0, 0, 0)
    @window.box(?|, ?-, ?+)
    @status = ''
  end

  def compose(in_reply_to = nil)
    if in_reply_to.is_a? Status
      @in_reply_to = in_reply_to
    else
      @in_reply_to = nil
    end

    @window.setpos(0, 0)
    begin
      system 'stty echo'
      curs_set(1)
      @status = readline(@in_reply_to.nil? ? ' > ' : " @#{in_reply_to.user.screen_name} ", true)
      system 'stty -echo'
      curs_set(0)
    rescue Interrupt
      clear
      Screen.instance.wait
    end
    post
  end

  def post
    return if @status.nil?

    ClientManager.instance.current.post(@status, @in_reply_to)
    Twterm::Config[:tweet] = @status
    clear
    Screen.instance.wait
  end

  def clear
    @status = ''
    Notifier.instance.clear
    refresh_window
  end

  def refresh_window
    @window.clear
    @window.addstr(@status)
    @window.refresh
  end
end
