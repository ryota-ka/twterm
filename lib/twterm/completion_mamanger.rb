module Twterm
  class CompletionManager
    def initialize(app)
      @app = app

      Readline.basic_word_break_characters = " \t\n\"\\'`$><=;|&{("
      Readline.completion_case_fold = false
    end

    def set_default_mode!
      Readline.completion_append_character = ' '

      Readline.completion_proc = proc do |str|
        if str.start_with?('#')
          app.hashtag_repository.all
          .map { |tag| "##{tag}" }
          .select { |tag| tag.start_with?(str) }
        elsif str.start_with?('@')
          app.user_repository.all
          .map { |user| "@#{user.screen_name}" }
          .select { |name| name.start_with?(str) }
        else
          []
        end
      end
    end

    def set_screen_name_mode!
      Readline.completion_append_character = ''

      Readline.completion_proc = proc do |str|
        app.user_repository.all
          .select { |name| name.start_with?(str) }
      end
    end

    private

    attr_reader :app
  end
end
