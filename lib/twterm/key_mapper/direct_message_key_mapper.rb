class Twterm::KeyMapper::DirectMessageKeyMapper < Twterm::KeyMapper::AbstractKeyMapper
  DEFAULT_MAPPINGS = {
    compose: 'n',
    reply: 'r',
  }.freeze

  def self.category
    'direct_message'
  end
end
