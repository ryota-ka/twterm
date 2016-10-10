require 'twterm/tab/base'
require_relative './../image'

module Twterm
  module Tab
    class KeyAssignmentsCheatsheet < Base
      include Scrollable

      def ==(other)
        other.is_a?(self.class)
      end

      SHORTCUTS = {
        'General' => {
          '[d] [C-d]'         => 'Scroll down',
          '[g]'               => 'Move to top',
          '[G]'               => 'Move to bottom',
          '[j] [C-p] [DOWN]'  => 'Move down',
          '[k] [C-n] [UP]'    => 'Move up',
          '[u] [C-u]'         => 'Scroll up',
          '[Q]'               => 'Quit twterm'
        },
        'Tabs' => {
          '[h] [C-b] [LEFT]'  => 'Previous tab',
          '[l] [C-f] [RIGHT]' => 'Next tab',
          '[N]'               => 'New tab',
          '[C-R]'             => 'Reload',
          '[w]'               => 'Close tab',
          '[q]'               => 'Quit filter mode',
          '[/]'               => 'Filter mode',
          '[1] - [9]'         => 'Nth tab',
          '[0]'               => 'Last tab'
        },
        'Tweets' => {
          '[c]'               => 'Conversation',
          '[D]'               => 'Delete',
          '[L]'               => 'Like',
          '[n]'               => 'New tweet',
          '[o]'               => 'Open URLs',
          '[r]'               => 'Reply',
          '[R]'               => 'Retweet',
          '[U]'               => 'User'
        },
        'Others' => {
          '[P]'               => 'My profile',
          '[?]'               => 'Key assignments cheatsheet'
        }
      }

      def drawable_item_count
        window.maxy - 3
      end

      def image
        SHORTCUTS
          .flat_map { |category, shortcuts|
            [
              !Image.string("<#{category}>"),
              Image.blank_line,
              *shortcuts.map { |key, description| !Image.string(key.rjust(17)) - Image.string(": #{description}") },
            ]
          }
          .intersperse(Image.blank_line)
          .drop(scroller.offset).reduce(Image.empty, :|)
      end

      def initialize
        super
        scroller.set_no_cursor_mode!
      end

      def respond_to_key(key)
        return true if scroller.respond_to_key(key)

        false
      end

      def title
        'Key assignments'.freeze
      end

      def total_item_count
        @count ||= SHORTCUTS.count * 4 + SHORTCUTS.values.map(&:count).reduce(0, :+) + 1
      end
    end
  end
end
