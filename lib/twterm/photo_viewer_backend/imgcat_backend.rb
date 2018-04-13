require 'curses'

require 'twterm/event/screen/refresh'
require 'twterm/photo_viewer_backend/abstract_photo_viewer_backend'
require 'twterm/publisher'

module Twterm
  module PhotoViewerBackend
    class ImgcatBackend < AbstractPhotoViewerBackend
      include Publisher

      def view(url)
        Curses.close_screen unless Curses.closed?

        puts "\e[H\e[2JDownloading..."

        with_downloaded_file(url) do |file|
          begin
            puts "\e[H\e[2JRendering..."
            system "imgcat #{file.path}"
            getc
          ensure
            puts "\e[H\e[2J"
            Curses.reset_prog_mode
            sleep 0.1
            publish(Event::Screen::Refresh.new)
          end
        end
      end
    end
  end
end

