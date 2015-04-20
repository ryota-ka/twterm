module Twterm
  class CompletionManager
    include Singleton

    def initialize
      Readline.basic_word_break_characters = " \t\n\"\\'`$><=;|&{("
      Readline.completion_case_fold = false
    end

    def set_default_mode!
      Readline.completion_append_character = ' '

      Readline.completion_proc = proc do |str|
        if str.start_with?('#')
          History::Hashtag.instance.history
          .map { |tag| "##{tag}" }
          .select { |tag| tag.start_with?(str) }
        elsif str.start_with?('@')
          History::ScreenName.instance.history
          .map { |name| "@#{name}" }
          .select { |name| name.start_with?(str) }
        else
          []
        end
      end
    end

    def set_screen_name_mode!
      Readline.completion_append_character = ''

      Readline.completion_proc = proc do |str|
        History::ScreenName.instance.history
          .select { |name| name.start_with?(str) }
      end
    end
  end
end
