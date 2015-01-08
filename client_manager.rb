require './client'

class ClientManager
  include Singleton

  def initialize
    @clients = []
  end

  def push(client)
    fail unless client.is_a? Client
    @clients << client
  end

  def current
    @clients[0]
  end
end
