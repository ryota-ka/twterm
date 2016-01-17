require 'twterm/publisher'
require 'twterm/user'
require 'twterm/utils'

module Twterm
  class DirectMessageComposer
    include Singleton
    include Readline
    include Curses
    include Publisher
    include Utils

    def compose(recipient)
      check_type User, recipient

      clear

      resetter = proc do
        reset_prog_mode
        sleep 0.1
        Screen.instance.refresh
      end

      thread = Thread.new do
        close_screen

        puts "\nCompose new message to @%s:" % recipient.screen_name

        CompletionManager.instance.set_default_mode!

        loop do
          line = (readline('> ', true) || '').strip
          break if line.empty?

          if line.end_with?('\\')
            @text << line.chop.rstrip + "\n"
          else
            @text << line
            break
          end
        end

        puts "\n"

        resetter.call
        send(recipient) unless text.empty?
      end

      App.instance.register_interruption_handler do
        thread.kill
        clear
        puts "\nCanceled"
        resetter.call
      end

      thread.join
    end

    private

    def clear
      @text = ''
    end

    def send(recipient)
      Client.current.create_direct_message(recipient, text)
      clear
    end

    def text
      @text || ''
    end
  end
end
