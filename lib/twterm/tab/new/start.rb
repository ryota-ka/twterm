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
          @title = 'New tab'
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
            tab.invoke_input
          when 'U'
            tab = Tab::New::User.new
            TabManager.instance.switch(tab)
            tab.invoke_input
          when 'x'
            tab = Tab::New::Track.new
            TabManager.instance.switch(tab)
            tab.invoke_input
          else
            return false
          end
          true
        end

        private

        def update
          @window.clear

          @window.bold do
            @window.setpos(2, 3)
            @window.addstr("You've opened a new tab")
          end

          @window.setpos(4, 5)
          @window.addstr('- [L] Open list tab')
          @window.bold do
            @window.setpos(4, 7)
            @window.addstr('[L]')
          end

          @window.setpos(6, 5)
          @window.addstr('- [S] Open search tab')
          @window.bold do
            @window.setpos(6, 7)
            @window.addstr('[S]')
          end

          @window.setpos(8, 5)
          @window.addstr('- [U] Open user tab')
          @window.bold do
            @window.setpos(8, 7)
            @window.addstr('[U]')
          end

          @window.setpos(11, 3)
          @window.addstr('To cancel opening a new tab, just press [w] to close this tab.')
          @window.bold do
            @window.setpos(11, 43)
            @window.addstr('[w]')
          end
          @window.refresh
        end
      end
    end
  end
end
