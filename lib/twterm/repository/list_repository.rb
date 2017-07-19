require 'twterm/repository/abstract_entity_repository'
require 'twterm/list'

module Twterm
  module Repository
    class ListRepository < AbstractEntityRepository
      private

      def type
        List
      end
    end
  end
end
