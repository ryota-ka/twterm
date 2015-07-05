module Twterm
  class Tweetbox
    class EmptyTextError < StandardError; end
    class InvalidCharactersError < StandardError; end
    class TextTooLongError < StandardError; end

    include Singleton
    include Readline
    include Curses

    def compose(in_reply_to = nil)
      @text = ''

      if in_reply_to.is_a? Status
        @in_reply_to = in_reply_to
      else
        @in_reply_to = nil
      end

      resetter = proc do
        reset_prog_mode
        sleep 0.1
        Screen.instance.refresh
      end

      thread = Thread.new do
        close_screen

        if in_reply_to.nil?
          puts "\nCompose new tweet:"
        else
          puts "\nReply to @#{in_reply_to.user.screen_name}'s tweet: \"#{in_reply_to.text}\""
        end

        CompletionManager.instance.set_default_mode!

        loop do
          loop do
            msg = in_reply_to.nil? || !text.empty? ? '> ' : "> @#{in_reply_to.user.screen_name} "
            line = (readline(msg, true) || '').strip
            break if line.empty?

            if line.end_with?('\\')
              @text << line.chop.rstrip + "\n"
            else
              @text << line
              break
            end
          end

          puts "\n"

          begin
            validate_text!
          rescue EmptyTextError
            break
          rescue InvalidCharactersError
            puts 'Status contains invalid characters'
          rescue TextTooLongError
            puts "Status is too long (#{text_length} / 140 characters)"
          end

          puts "\n"
          clear
        end

        resetter.call
        post
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

    attr_reader :in_reply_to

    def clear
      @text = ''
      @in_reply_to = nil
    end

    def post
      validate_text!
      Client.current.post(text, in_reply_to)
    rescue
      puts 'Some exception'
    ensure
      clear
    end

    def text
      @text || ''
    end

    def text_length
      Twitter::Validation.tweet_length(text)
    end

    def validate_text!
      case Twitter::Validation.tweet_invalid?(text)
      when :empty
        fail EmptyTextError
      when :invalid_characters
        fail InvalidCharactersError
      when :too_long
        fail TextTooLongError
      end
    end
  end
end
