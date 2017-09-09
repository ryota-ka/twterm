require 'twterm/event/user_garbage_collected'
require 'twterm/repository/abstract_expirable_entity_repository'
require 'twterm/user'

module Twterm
  module Repository
    class UserRepository < AbstractExpirableEntityRepository
      def all
        repository.values
      end

      def ids
        repository.keys
      end

      private

      def garbage_collection_event_class
        Event::UserGarbageCollected
      end

      def should_keep?(_)
        true
      end

      def type
        User
      end
    end
  end
end
