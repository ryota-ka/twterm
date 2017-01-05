require_relative './abstract_key_mapper'

module Twterm
  class KeyMapper
    class TabKeyMapper < Twterm::KeyMapper::AbstractKeyMapper
      DEFAULT_MAPPINGS = {
        :'1st' => '1',
        :'2nd' => '2',
        :'3rd' => '3',
        :'4th' => '4',
        :'5th' => '5',
        :'6th' => '6',
        :'7th' => '7',
        :'8th' => '8',
        :'9th' => '9',
        close: 'w',
        last: '0',
        new: 'N',
        reload: '^R',
        search_upward: '?',
        search_downward: '/',
      }.freeze

      def self.category
        'tab'.freeze
      end
    end
  end
end
