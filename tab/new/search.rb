module Tab
  module New
    class Search
      include Base
      include Readline

      def initialize
        super

        @title = 'New tab'
        @window.refresh
      end

      def respond_to_key(_)
        false
      end

      def invoke_input
        input_thread = Thread.new do
          close_screen
          puts "\ninput search query"
          query = readline('input query > ')
          reset_prog_mode

          if query.empty?
            tab = Tab::New::Start.new
            TabManager.instance.switch(tab)
          else
            tab = Tab::SearchTab.new(query)
            TabManager.instance.switch(tab)
          end

          Screen.instance.refresh
        end

        App.instance.register_interruption_handler do
          input_thread.kill
          reset_prog_mode
          tab = Tab::New::Start.new
          TabManager.instance.switch(tab)
          Screen.instance.refresh
        end

        input_thread.join
      end

      private

      def update; end
    end
  end
end
