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

    thread = Thread.new do
      system 'stty echo'
      curs_set(1)
      @status = readline(@in_reply_to.nil? ? ' > ' : " @#{in_reply_to.user.screen_name} ", true)
      curs_set(0)
      post
    end

    App.instance.register_interruption_handler do
      thread.kill
      clear
      curs_set(0)
    end

    thread.join
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
