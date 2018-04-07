require 'twterm/image'

module Twterm
  module ImageBuilder
    class UserNameImageBuilder
      COLORS = [:red, :blue, :green, :cyan, :yellow, :magenta].freeze

      # @param factory [Twterm::ImageFactory]
      # @param user [Twterm::User] user
      def initialize(factory, user)
        @factory = factory
        @user = user
      end

      # @return [Twterm::Image] image for the given user
      def build
        i = factory
        !i.string(user.name).color(color) - i.whitespace - i.string("@#{user.screen_name}").parens
      end

      private

      attr_reader :factory, :user

      # @return [Symbol] color for user
      def color
        COLORS[user.id % 6]
      end
    end
  end
end
