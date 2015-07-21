module Twterm
  module Tab
    module New
      class Start
        include Base

        def ==(other)
          other.is_a?(self.class)
        end

        def initialize
          super
          refresh
        end

        def respond_to_key(key)
          case key
          when 'L'
            tab = Tab::New::List.new
            TabManager.instance.switch(tab)
          when 'S'
            tab = Tab::New::Search.new
            TabManager.instance.switch(tab)
          when 'U'
            tab = Tab::New::User.new
            TabManager.instance.switch(tab)
            tab.invoke_input
          else
            return false
          end
          true
        end

        def title
          'New tab'.freeze
        end

        private

        def update
          window.setpos(2, 3)
          window.bold { window.addstr("You've opened a new tab") }

          window.setpos(4, 5)
          window.addstr('- [L] Open list tab')
          window.setpos(4, 7)
          window.bold { window.addstr('[L]') }

          window.setpos(6, 5)
          window.addstr('- [S] Open search tab')
          window.setpos(6, 7)
          window.bold { window.addstr('[S]') }

          window.setpos(8, 5)
          window.addstr('- [U] Open user tab')
          window.setpos(8, 7)
          window.bold { window.addstr('[U]') }

          window.setpos(11, 3)
          window.addstr('To cancel opening a new tab, just press [w] to close this tab.')
          window.setpos(11, 43)
          window.bold { window.addstr('[w]') }
        end
      end
    end
  end
end
