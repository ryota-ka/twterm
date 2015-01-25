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

        @window.setpos(8, 5)
        @window.addstr('To cancel opening a new tab, just press [w]')
        @window.refresh
      end
    end
  end
end
