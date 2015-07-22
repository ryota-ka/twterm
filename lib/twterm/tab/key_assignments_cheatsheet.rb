module Twterm
  module Tab
    class KeyAssignmentsCheatsheet
      include Base
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
          '[h] [C-b] [LEFT]'  => 'Show previous tab',
          '[l] [C-f] [RIGHT]' => 'Show next tab',
          '[N]'               => 'Open new tab',
          '[C-R]'             => 'Reload',
          '[w]'               => 'Close tab',
          '[q]'               => 'Quit filtering mode',
          '[/]'               => 'Filter items in tab'
        },
        'Tweets' => {
          '[D]'               => 'Delete tweet',
          '[F]'               => 'Add to favorite',
          '[n]'               => 'Compose new tweet',
          '[o]'               => 'Open URLs in tweet',
          '[r]'               => 'Reply',
          '[R]'               => 'Retweet',
          '[U]'               => 'Show user'
        },
        'Others' => {
          '[P]'               => 'View my profile',
          '[?]'               => 'Open key assignments cheatsheet'
        }
      }

      def drawable_item_count
        window.maxy - 3
      end

      def initialize
        super
        scroller.set_cursor_free!
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

      def update
        offset = scroller.offset
        line = 0

        window.setpos(line - offset + 2, 3)
        window.bold { window.addstr('Key assignments') } if scroller.nth_item_drawable?(line)

        SHORTCUTS.each do |category, shortcuts|
          line += 3
          window.setpos(line - offset + 2, 5)
          window.bold { window.addstr("<#{category}>") } if scroller.nth_item_drawable?(line)
          line += 1

          shortcuts.each do |key, description|
            line += 1
            next unless scroller.nth_item_drawable?(line)

            window.setpos(line - offset + 2, 7)
            window.bold { window.addstr(key.rjust(17)) }
            window.setpos(line - offset + 2, 25)
            window.addstr(": #{description}")
          end
        end
      end
    end
  end
end
