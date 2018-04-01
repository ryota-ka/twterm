module Twterm
  class Hashtag
    attr_reader :text

    def initialize(hashtag)
      @text = hashtag.text
    end
  end
end
