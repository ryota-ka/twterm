require 'twterm/publisher'
require 'twterm/event/message/error'
require 'twterm/event/screen/refresh'

module Twterm
  class Tweetbox
    class EmptyTextError < StandardError; end
    class TextTooLongError < StandardError
      def initialize(parse_result)
        @parse_result = parse_result
      end

      def message
        "Text is too long (weighted length: #{@parse_result[:weighted_length]} / 280)"
      end
    end

    include Readline
    include Curses
    include Publisher

    def initialize(app, client)
      @app, @client = app, client
    end

    def compose
      ask_and_post("\e[1mCompose new Tweet\e[0m", '> ', -> body { body })
    end

    def quote(status)
      screen_name = app.user_repository.find(status.user_id).screen_name
      leading_text = "\e[1mQuoting @#{screen_name}'s Tweet\e[0m\n\n#{status.text}"
      prompt = '> '

      ask_and_post(leading_text, prompt, -> body { "#{body} #{status.url}" })
    end

    def reply(status)
      screen_name = app.user_repository.find(status.user_id).screen_name
      leading_text = "\e[1mReplying to @#{screen_name}\e[0m\n\n#{status.text}"
      prompt = { prompt: '> ', init_text: "@#{screen_name} " }

      ask_and_post(leading_text, prompt, -> body { body }, { in_reply_to_status_id: status.id })
    end

    private

    attr_reader :app, :client, :in_reply_to

    def ask(prompt, postprocessor, &cont)
      app.completion_manager.set_default_mode!

      thread = Thread.new do
        if prompt.is_a?(Hash)
          if prompt.include?(:init_text)
            init_readline_text(prompt[:init_text])
          end
          prompt = prompt[:prompt] || '> '
        end

        raw_text = ''

        loop do
          loop do
            line = (readline(prompt, true) || '').strip
            break if line.empty?

            if line.end_with?('\\')
              raw_text << line.chop.rstrip + "\n"
            else
              raw_text << line
              break
            end
          end

          puts "\n"

          text = postprocessor.call(raw_text)

          begin
            validate!(text)
            break
          rescue EmptyTextError
            break
          rescue TextTooLongError => e
            puts e.message
          end

          puts "\n"
          raw_text = ''
        end

        reset
        cont.call(raw_text) unless raw_text.empty?
      end

      app.register_interruption_handler do
        thread.kill
        puts "\nCanceled"
        reset
      end

      thread.join
    end

    def ask_and_post(leading_text, prompt, postprocessor, options = {})
      close_screen
      puts "\e[H\e[2J#{leading_text}\n\n"
      ask(prompt, postprocessor) { |text| client.post(postprocessor.call(text), options) }
    end

    def init_readline_text(text)
      old_pre_input_hook = Readline.pre_input_hook
      Readline.pre_input_hook = lambda do
        old_pre_input_hook.call if old_pre_input_hook
        Readline.insert_text(text)
        Readline.redisplay
        Readline.pre_input_hook = old_pre_input_hook
      end
    end

    def reset
      reset_prog_mode
      sleep 0.1
      publish(Event::Screen::Refresh.new)
    end

    def text_length(text)
      Twitter::TwitterText::Validation.tweet_length(text)
    end

    def validate!(text)
      raise EmptyTextError if text.empty?

      result = Twitter::TwitterText::Validation.parse_tweet(text)
      valid = result[:valid]

      raise TextTooLongError.new(result) unless valid
    end
  end
end
