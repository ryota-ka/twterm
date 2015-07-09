module Twterm
  module Tab
    class KeyAssignmentsCheatsheet
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
          '[?]'               => 'Open key assignments cheatsheet'
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

      def respond_to_key(key)
        case key
        when ?d, 4
          10.times { scroller.move_down }
        when ?g
          scroller.move_to_top
        when ?G
          scroller.move_to_bottom
        when ?j, 14, Curses::Key::DOWN
          scroller.move_down
        when ?k, 16, Curses::Key::UP
          scroller.move_up
        when ?u, 21
          10.times { scroller.move_up }
        else
          return false
        end

        true
      end

      def title
        'Key assignments'.freeze
      end

      def update
        top = 2 # begin drawing from line 2
        draw_cond = -> line { top <= line && line <= window.maxy - top }

        current_line = top - scroller.offset

        window.setpos(current_line, 3)
        window.bold { window.addstr('Key assignments') } if draw_cond[current_line]

        SHORTCUTS.each do |category, shortcuts|
          current_line += 3
          window.setpos(current_line, 5)
          window.bold { window.addstr("<#{category}>") } if draw_cond[current_line]
          current_line += 1

          shortcuts.each do |key, description|
            current_line += 1
            next unless draw_cond[current_line]

            window.setpos(current_line, 7)
            window.bold { window.addstr(key.rjust(17)) }
            window.setpos(current_line, 25)
            window.addstr(": #{description}")
          end
        end
      end

      private

      def count
        @count ||= SHORTCUTS.count * 4 + SHORTCUTS.map(&:count).reduce(0, :+) + 1
      end

      def offset_from_bottom
        0
      end
    end
  end
end
