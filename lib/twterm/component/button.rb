require 'twterm/component/abstract_component'
require 'twterm/image'

module Twterm
  module Component
    class Button < AbstractComponent
      def initialize(message, &block)
        @message = message
        @block = block
      end

      def image
        Image.string(message).color(:black, :white)
      end

      def perform
        block.call
      end

      private

      attr_reader :block, :message
    end
  end
end
