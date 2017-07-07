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

      def type
        User
      end
    end
  end
end
