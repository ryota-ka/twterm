require 'twterm/image'

module Twterm
  # @todo Rename to `Presenter`
  module ImageBuilder
    class UserNameImageBuilder
      COLORS = [:red, :blue, :green, :cyan, :yellow, :magenta].freeze

      # @param user [Twterm::User] user
      def initialize(user)
        @user = user
      end

      # @return [Twterm::Image] image for the given user
      def build
        !Image.string(user.name).color(color) - Image.whitespace - Image.string("@#{user.screen_name}").parens
      end

      private

      attr_reader :user

      # @return [Symbol] color for user
      def color
        COLORS[user.id % 6]
      end
    end
  end
end
