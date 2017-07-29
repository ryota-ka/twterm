require 'twterm/key_mapper/abstract_key_mapper'

class Twterm::KeyMapper::GeneralKeyMapper < Twterm::KeyMapper::AbstractKeyMapper
  DEFAULT_MAPPINGS = {
    bottom: 'G',
    down: 'j',
    left: 'h',
    page_down: 'd',
    page_up: 'u',
    right: 'l',
    top: 'g',
    up: 'k',
  }.freeze

  def self.category
    'general'.freeze
  end
end
