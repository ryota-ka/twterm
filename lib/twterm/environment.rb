require 'terminal-notifier'

module Twterm
  class Environment
    def initialize
      @uname = `uname`.strip

      @terminal_notifier_available = TerminalNotifier.available?
      @with_eog = system('which eog >/dev/null 2>&1')
      @with_imgcat = system('which imgcat >/dev/null 2>&1')
      @with_tmux = system('which tmux >/dev/null 2>&1') && !ENV['TMUX'].nil?
      @with_qlmanage = system('which qlmanage >/dev/null 2>&1')
    end

    def darwin?
      @uname == 'Darwin'
    end

    def linux?
      @uname == 'Linux'
    end

    def terminal_notifier_available?
      @terminal_notifier_available
    end

    def with_eog?
      @with_eog
    end

    def with_imgcat?
      @with_imgcat
    end

    def with_qlmanage?
      @with_qlmanage
    end

    def with_tmux?
      @with_tmux
    end
  end
end
