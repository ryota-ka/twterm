require 'bundler'
Bundler.require

class Client
  private_class_method :new

  def initialize(token, secret)
    @rest_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = 'vLNSVFgXclBJQJRZ7VLMxL9lA'
      config.consumer_secret     = 'OFLKzrepRG2p1hq0nUB9j2S9ndFQoNTPheTpmOY0GYw55jGgS5'
      config.access_token        = token
      config.access_token_secret = secret
    end

    UserStream.configure do |config|
      config.consumer_key       = 'vLNSVFgXclBJQJRZ7VLMxL9lA'
      config.consumer_secret    = 'OFLKzrepRG2p1hq0nUB9j2S9ndFQoNTPheTpmOY0GYw55jGgS5'
      config.oauth_token        = token
      config.oauth_token_secret = secret
    end

    @stream_client = UserStream.client
  end

  def stream(timeline)
    Thread.new do
      @stream_client.user do |status|
        timeline.push(Status.new(status)) unless status.text.nil?
      end
    end
  end

  def post(text, in_reply_to = nil)
    Thread.new do
      if in_reply_to.is_a? Status
        text = "@#{in_reply_to.user.screen_name}: #{text}"
        @rest_client.update(text, in_reply_to_status_id: in_reply_to.id)
      else
        @rest_client.update(text)
      end
    end
  end

  def home
    @rest_client.home_timeline.map do |tweet|
      Status.new(tweet)
    end
  end

  def self.create(token, secret)
    client = new(token, secret)
    ClientManager.instance.push(client)
    client
  end
end
