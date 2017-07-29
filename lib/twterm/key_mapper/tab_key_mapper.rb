require 'twterm/key_mapper/abstract_key_mapper'

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
        find_next: 'n',
        find_previous: 'N',
        last: '0',
        new: '^T',
        reload: '^R',
        search_down: '/',
        search_up: '?',
      }.freeze

      def self.category
        'tab'.freeze
      end
    end
  end
end
