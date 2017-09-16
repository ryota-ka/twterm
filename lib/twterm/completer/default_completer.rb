require 'twterm/completer/abstract_completer'

module Twterm
  module Completer
    class DefaultCompleter < AbstractCompleter
      def complete(query)
        if query.start_with?('#')
          app.hashtag_repository.all
          .map { |tag| "##{tag}" }
          .select { |tag| tag.start_with?(query) }
        elsif query.start_with?('@')
          app.user_repository.all
          .map { |user| "@#{user.screen_name}" }
          .select { |name| name.start_with?(query) }
        else
          []
        end
      end
    end
  end
end
