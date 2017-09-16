require 'twterm/completer/default_completer'
require 'twterm/completer/screen_name_completer'
require 'twterm/completer/search_query_completer'

module Twterm
  class CompletionManager
    def initialize(app)
      @app = app

      Readline.completion_case_fold = false
    end

    def set_default_mode!
      complete_with!(Completer::DefaultCompleter.new(app))
    end

    def set_screen_name_mode!
      complete_with!(Completer::ScreenNameCompleter.new(app))
    end

    def set_search_mode!
      complete_with!(Completer::SearchQueryCompleter.new(app))
    end

    private

    attr_reader :app

    def complete_with!(completer)
      Readline.basic_word_break_characters = completer.basic_word_break_characters
      Readline.completion_append_character = completer.completion_append_character
      Readline.completion_proc = -> q { completer.complete(q) }

      self
    end
  end
end
