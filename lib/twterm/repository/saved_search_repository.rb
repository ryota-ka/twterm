require 'twterm/repository/abstract_entity_repository'
require 'twterm/saved_search'

module Twterm
  module Repository
    class SavedSearchRepository < AbstractEntityRepository
      private

      def type
        SavedSearch
      end
    end
  end
end
