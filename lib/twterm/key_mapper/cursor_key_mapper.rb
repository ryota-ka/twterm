require_relative './abstract_key_mapper'

class Twterm::KeyMapper::CursorKeyMapper < Twterm::KeyMapper::AbstractKeyMapper
  DEFAULT_MAPPINGS = {
    bottom_of_window: 'L',
    middle_of_window: 'M',
    top_of_window: 'H',
  }.freeze

  def self.category
    'cursor'.freeze
  end
end
