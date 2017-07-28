require 'twterm/publisher'
require 'twterm/user'
require 'twterm/utils'

module Twterm
  class DirectMessageComposer
    include Readline
    include Curses
    include Publisher
    include Utils

    def initialize(app, client)
      @app, @client = app, client
    end

    def compose(recipient)
      check_type User, recipient

      clear

      resetter = proc do
        reset_prog_mode
        sleep 0.1
        app.screen.refresh
      end

      thread = Thread.new do
        close_screen

        puts "\nCompose new message to @%s:" % recipient.screen_name

        app.completion_manager.set_default_mode!

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

      app.register_interruption_handler do
        thread.kill
        clear
        puts "\nCanceled"
        resetter.call
      end

      thread.join
    end

    private

    attr_reader :app, :client

    def clear
      @text = ''
    end

    def send(recipient)
      client.create_direct_message(recipient, text)
      clear
    end

    def text
      @text || ''
    end
  end
end
