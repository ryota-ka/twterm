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
      page_down
      page_up
      right
      top
      up
    ).freeze
  end
end
