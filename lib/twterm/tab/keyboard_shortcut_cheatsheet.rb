module Twterm
  module Tab
    class KeyboardShortcutCheatsheet
      include Base

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
          '[Q]'               => 'Quit twterm',
          '[?]'               => 'Open keyboard shortcut cheatsheet'
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
        }
      }

      def respond_to_key(_)
        false
      end

      def title
        'Keyboard shortcuts'.freeze
      end

      def update
        current_line = 2

        window.setpos(current_line, 3)
        window.bold { window.addstr('Keyboard shortcuts') }

        SHORTCUTS.each do |category, shortcuts|
          current_line += 3
          window.setpos(current_line, 5)
          window.bold { window.addstr("<#{category}>") }
          current_line += 1

          shortcuts.each do |key, description|
            current_line += 1
            window.setpos(current_line, 7)
            window.bold { window.addstr(key.rjust(17)) }
            window.setpos(current_line, 25)
            window.addstr(": #{description}")
          end
        end
      end
    end
  end
end
