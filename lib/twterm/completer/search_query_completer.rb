require 'twterm/completer/abstract_completer'

module Twterm
  module Completer
    class SearchQueryCompleter < AbstractCompleter
      def completion_append_character
        ''
      end

      def complete(q)
        possible_operators = possible_operators_for_query(q)

        if q.empty?
          operators
        elsif q.start_with?('#')
          app.hashtag_repository.all
          .map { |tag| "##{tag} " }
          .select { |tag| tag.start_with?(q) }
        elsif q.start_with?('@')
          app.user_repository.all
          .map { |user| "@#{user.screen_name} " }
          .select { |name| name.start_with?(q) }
        elsif !possible_operators.empty?
          possible_operators
        elsif q.start_with?('-from:')
          app.user_repository.all
            .map { |user| "-from:#{user.screen_name} " }
            .select { |name| name.start_with?(q) }
        elsif q.start_with?('from:')
          app.user_repository.all
            .map { |user| "from:#{user.screen_name} " }
            .select { |name| name.start_with?(q) }
        elsif q.start_with?('-to:')
          app.user_repository.all
            .map { |user| "-to:#{user.screen_name} " }
            .select { |name| name.start_with?(q) }
        elsif q.start_with?('to:')
          app.user_repository.all
            .map { |user| "to:#{user.screen_name} " }
            .select { |name| name.start_with?(q) }
        elsif q.start_with?('filter:')
          filters.map { |f| "filter:#{f} " }.select { |f| f.start_with?(q) }
        elsif q.start_with?('-filter:')
          filters.map { |f| "-filter:#{f} " }.select { |f| f.start_with?(q) }
        elsif q.start_with?('lang:')
          langs.map { |l| "lang:#{l} " }.select { |l| l.start_with?(q) }
        elsif q.start_with?('-lang:')
          langs.map { |l| "-lang:#{l} " }.select { |l| l.start_with?(q) }
        elsif q.start_with?('list:')
          app.list_repository.all
            .map { |list| "list:#{list.full_name.sub('@', '')} " }
            .select { |name| name.start_with?(q) }
        else
          []
        end
      end

      private

      def filters
        [
          'images',
          'links',
          'media',
          'native_video',
          'periscope',
          'retweets',
          'safe',
          'twimg',
          'vine',
        ]
      end

      def langs
        [
          'am',
          'ar',
          'bg',
          'bn',
          'bo',
          'ckb',
          'da',
          'de',
          'dv',
          'el',
          'en',
          'es',
          'et',
          'fa',
          'fi',
          'fr',
          'gu',
          'he',
          'hi',
          'ht',
          'hu',
          'hy',
          'id',
          'is',
          'it',
          'ja',
          'ka',
          'km',
          'kn',
          'ko',
          'lo',
          'lt',
          'lv',
          'ml',
          'mr',
          'my',
          'ne',
          'nl',
          'no',
          'or',
          'pa',
          'pl',
          'ps',
          'pt',
          'ro',
          'ru',
          'sd',
          'si',
          'sl',
          'sr',
          'sv',
          'ta',
          'te',
          'th',
          'tl',
          'tr',
          'ug',
          'ur',
          'vi',
          'zh',
        ]
      end

      def nullary_operators
        [
          ':(',
          ':)',
          '?',
          'OR',
        ]
      end

      def operators
        nullary_operators + unary_operators
      end

      def possible_operators_for_query(q)
        (nullary_operators.map { |o| "#{o} " } + unary_operators).select { |x| x.start_with?(q) && x != q }
      end

      def substrs(str)
        0.upto(str.length - 1).map { |n| str.slice(0...n) }
      end

      def unary_operators
        [
          '-filter:',
          '-from:',
          '-lang:',
          '-to:',
          '-url:',
          '@',
          'filter:',
          'from:',
          'lang:',
          'list:',
          'since:',
          'to:',
          'until:',
          'url:',
        ]
      end
    end
  end
end
