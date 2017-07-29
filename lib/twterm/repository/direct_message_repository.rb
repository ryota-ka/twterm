require 'twterm/direct_message'
require 'twterm/repository/abstract_entity_repository'

module Twterm
  module Repository
    class DirectMessageRepository < AbstractEntityRepository
      private

      def type
        DirectMessage
      end
    end
  end
end
