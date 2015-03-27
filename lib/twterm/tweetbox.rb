module Twterm
  class Tweetbox
    include Singleton
    include Readline
    include Curses

    def initialize
      @status = ''
    end

    def compose(in_reply_to = nil)
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

        if @in_reply_to.nil?
          puts "\nCompose new tweet:"
        else
          puts "\nReply to @#{@in_reply_to.user.screen_name}'s tweet: \"#{@in_reply_to.text}\""
        end

        Readline.completion_append_character = ' '
        Readline.basic_word_break_characters = " \t\n\"\\'`$><=;|&{("
        Readline.completion_proc = proc do |str|
          if str.start_with?('#')
            HashtagManager.instance.tags
              .map { |tag| "##{tag}" }
              .select { |tag| tag.downcase.start_with?(str.downcase) }
          elsif str.start_with?('@')
            ScreenNameManager.instance.screen_names
              .map { |name| "@#{name}" }
              .select! { |name| name.downcase.start_with?(str.downcase) }
          else
            []
          end
        end

        loop do
          msg = @in_reply_to.nil? || !@status.empty? ? '> ' : "> @#{in_reply_to.user.screen_name} "
          line = (readline(msg, true) || '').strip
          break if line.empty?

          if line.end_with?('\\')
            @status << line.chop.lstrip + "\n"
          else
            @status << line
            break
          end
        end

        resetter.call
        post
      end

      App.instance.register_interruption_handler do
        thread.kill
        clear
        puts "\ncanceled"
        resetter.call
      end

      thread.join
    end

    def post
      return if @status.nil? || @status.empty?

      Client.current.post(@status, @in_reply_to)
      clear
    end

    def clear
      @status = ''
    end
  end
end
