module Auth
  def authenticate_user
    consumer = OAuth::Consumer.new(
      'vLNSVFgXclBJQJRZ7VLMxL9lA',
      'OFLKzrepRG2p1hq0nUB9j2S9ndFQoNTPheTpmOY0GYw55jGgS5',
      site: 'https://api.twitter.com'
    )
    request_token = consumer.get_request_token
    Launchy.open request_token.authorize_url
    print 'input PIN: '
    pin = (STDIN.gets || '').strip
    access_token = request_token.get_access_token(oauth_verifier: pin)

    Config[:access_token] = access_token.token
    Config[:access_token_secret] = access_token.secret
    Config[:screen_name] = access_token.params[:screen_name]
    Config[:user_id] = access_token.params[:user_id]
  end

  module_function :authenticate_user
end
