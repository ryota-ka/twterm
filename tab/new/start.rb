module Tab
  module New
    class Start
      include Base

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
        else
          return false
        end
        true
      end

      def ==(other)
        other.is_a?(self.class)
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

        @window.setpos(9, 3)
        @window.addstr('To cancel opening a new tab, just press [w] to close this tab.')
        @window.bold do
          @window.setpos(9, 43)
          @window.addstr('[w]')
        end
        @window.refresh
      end
    end
  end
end
