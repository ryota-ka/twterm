require 'time'

class Status
  attr_reader :id, :text, :created_at, :retweet_count, :favorite_count, :user

  def initialize(tweet)
    @id = tweet.id
    @text = tweet.text
    @created_at = tweet.created_at.is_a?(String) ? Time.parse(tweet.created_at) : tweet.created_at
    @retweet_count = tweet.retweet_count
    @favorite_count = tweet.favorite_count

    @favorited = tweet.favorited?

    @user = User.new(tweet.user)

    @formatted_text = {}
  end

  def favorited?
    @favorited
  end

  def format(width)
    @formatted_text[width] ||=
    @text.split("\n").map do |line|
      ('    ' + line).scan(/.{1,#{width}}/).map { |l| l.mb_ljust(width) }.join
    end.join
  end

  def formatted_lines(width)
    (format(width).length / width.to_f).ceil
  end
end
