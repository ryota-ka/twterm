require_relative './abstract_key_mapper'

class Twterm::KeyMapper::GeneralKeyMapper < Twterm::KeyMapper::AbstractKeyMapper
  def self.category
    'general'.freeze
  end

  def self.commands
    %i(
      bottom
      cancel
      down
      left
      right
      scroll_down
      scroll_up
      top
      up
    ).freeze
  end
end
