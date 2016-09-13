require 'curses'

module Twterm
  class KeyMapper
    class AbstractKeyMapper
      class NoSuchCommand < StandardError; end
      class NoSuchKey < StandardError; end

      def initialize(mappings)
        commands = self.class.commands

        mappings.keys.each do |k|
          raise NoSuchCommand, "#{self.class.category}.#{k}" unless commands.include?(k)
        end

        @mappings = Hash[mappings.map { |k, v| [k, translate(v)] }]
      end

      def [](key)
        @mappings[key]
      end

      private

      def translate(key)
        case key
        when '!'..'}' then key
        when /\A<C-([a-z]?)>\Z/ then $1.ord - 'a'.ord + 1
        when /\A<C-([A-Z]?)>\Z/ then $1.ord - 'A'.ord + 1
        when '<Backspace>' then 127
        when '<Down>' then Curses::Key::DOWN
        when '<Esc>' then 27
        when '<F1>' then Curses::Key::F1
        when '<F2>' then Curses::Key::F2
        when '<F3>' then Curses::Key::F3
        when '<F4>' then Curses::Key::F4
        when '<F5>' then Curses::Key::F5
        when '<F6>' then Curses::Key::F6
        when '<F7>' then Curses::Key::F7
        when '<F8>' then Curses::Key::F8
        when '<F9>' then Curses::Key::F9
        when '<F10>' then Curses::Key::F10
        when '<F11>' then Curses::Key::F11
        when '<F12>' then Curses::Key::F12
        when '<Left>' then Curses::Key::LEFT
        when '<Right>' then Curses::Key::RIGHT
        when '<Space>' then ' '
        when '<Up>' then Curses::Key::UP
        else
          raise NoSuchKey, key
        end
      end

      def self.commands
        raise NotImplementedError, 'commands methods must be implemented'
      end
    end
  end
end
