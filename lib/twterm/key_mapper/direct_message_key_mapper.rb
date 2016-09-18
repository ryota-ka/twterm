class Twterm::KeyMapper::DirectMessageKeyMapper < Twterm::KeyMapper::AbstractKeyMapper
  def self.category
    'direct_message'
  end

  def self.commands
    %i(
      compose
      reply
    ).freeze
  end
end
