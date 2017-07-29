require 'twterm/key_mapper/abstract_key_mapper'

class Twterm::KeyMapper::AppKeyMapper < Twterm::KeyMapper::AbstractKeyMapper
  DEFAULT_MAPPINGS = {
    cheatsheet: 'F1',
    me: 'm',
    quit: 'F10',
  }.freeze

  def self.category
    'app'.freeze
  end
end
