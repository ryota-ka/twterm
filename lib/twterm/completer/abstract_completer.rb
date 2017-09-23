module Twterm
  module Completer
    class AbstractCompleter
      def initialize(app)
        @app = app
      end

      def basic_word_break_characters
        " \t\n\"\\'`$><=;|&{("
      end

      def complete(_query)
        raise NotImplementedError, '`complete` method must be implemented'
      end

      def completion_append_character
        ' '
      end

      private

      attr_reader :app
    end
  end
end
