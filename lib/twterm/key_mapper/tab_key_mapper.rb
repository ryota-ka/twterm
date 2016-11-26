require_relative './abstract_key_mapper'

module Twterm
  class KeyMapper
    class TabKeyMapper < Twterm::KeyMapper::AbstractKeyMapper
      def self.category
        'tab'.freeze
      end

      def self.commands
        %i(
          1st
          2nd
          3rd
          4th
          5th
          6th
          7th
          8th
          9th
          close
          find_next
          find_previous
          last
          new
          reload
          search_downward
          search_upward
        ).freeze
      end
    end
  end
end
