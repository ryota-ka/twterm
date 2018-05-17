require 'twterm/image'
require 'twterm/tab/abstract_tab'
require 'twterm/tab/searchable'

module Twterm
  module Tab
    class KeyAssignmentsCheatsheet < AbstractTab
      include Scrollable

      def ==(other)
        other.is_a?(self.class)
      end

      SHORTCUTS = {
        ['General', :general] => {
          page_down: 'Page down',
          top: 'Move to top',
          bottom: 'Move to bottom',
          down: 'Move down',
          up: 'Move up',
          page_up: 'Page up',
          left: 'Left',
          right: 'Right',
        },
        ['Tabs', :tab] => {
          new: 'New tab',
          reload: 'Reload',
          close: 'Close tab',
          search_down: 'Search down',
          search_up: 'Search up',
          find_next: 'Find next',
          find_previous: 'Find previous',
        },
        ['Tweets', :status] => {
          compose: 'New tweet',
          conversation: 'Conversation',
          destroy: 'Delete',
          like: 'Like',
          open_link: 'Open URLs',
          reply: 'Reply',
          retweet: 'Retweet',
          quote: 'Quote',
          user: 'User',
        },
        ['Cursor', :cursor] => {
          top_of_window: 'Top of window',
          middle_of_window: 'Middle of window',
          bottom_of_window: 'Bottom of window'
        },
        ['Others', :app] => {
          me: 'My profile',
          cheatsheet: 'Key assignments cheatsheet',
          quit: 'Quit',
        }
      }

      def drawable_item_count
        window.maxy - 3
      end

      def image
        k = KeyMapper.instance

        SHORTCUTS
          .flat_map { |(cat_str, cat_sym), shortcuts|
            [
              !Image.string(cat_str).color(:green),
              Image.blank_line,
              *shortcuts.map { |cmd, desc|
                Image.string('  ') - !Image.string(k.as_string(cat_sym, cmd).center(3)).color(:cyan) - Image.whitespace - Image.string(desc)
              },
              Image.blank_line,
            ]
          }
          .drop(scroller.offset)
          .take(drawable_item_count)
          .reduce(Image.empty, :|)
      end

      def initialize(app, client)
        super(app, client)
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
