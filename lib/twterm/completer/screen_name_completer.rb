require 'twterm/completer/abstract_completer'

module Twterm
  module Completer
    class ScreenNameCompleter < AbstractCompleter
      def complete(query)
        app.user_repository.all
          .map { |user| user.screen_name }
          .select { |name| name.start_with?(query) }
      end

      def completion_append_character
        ''
      end
    end
  end
end
