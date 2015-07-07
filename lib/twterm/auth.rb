module Twterm
  module Auth
    def authenticate_user(config)
      consumer = OAuth::Consumer.new(
        'vLNSVFgXclBJQJRZ7VLMxL9lA',
        'OFLKzrepRG2p1hq0nUB9j2S9ndFQoNTPheTpmOY0GYw55jGgS5',
        site: 'https://api.twitter.com'
      )
      request_token = consumer.get_request_token
      url = request_token.authorize_url
      begin
        Launchy.open(url)
      rescue Launchy::CommandNotFoundError
        puts "Open the following URL to authorize yourself: #{url}"
      end
      print 'Input PIN: '
      pin = (STDIN.gets || '').strip
      access_token = request_token.get_access_token(oauth_verifier: pin)

      config[:access_token] = access_token.token
      config[:access_token_secret] = access_token.secret
      config[:screen_name] = access_token.params[:screen_name]
      config[:user_id] = access_token.params[:user_id]
    end

    module_function :authenticate_user
  end
end
