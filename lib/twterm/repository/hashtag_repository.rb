require 'twterm/hashtag'
require 'twterm/repository/abstract_repository'

module Twterm
  module Repository
    class HashtagRepository < AbstractRepository
      def initialize
        @m = Mutex.new

        super
      end

      def all
        repository.to_a
      end

      private

      def empty_repository
        Set.new
      end

      def extract_key(args)
        args[0]
      end

      def find(key)
        repository.include?(key) ? key : nil
      end

      def store(hashtag)
        @m.synchronize { repository << hashtag }
      end

      def type
        Hashtag
      end
    end
  end
end
