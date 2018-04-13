require 'twterm/photo_viewer_backend/abstract_photo_viewer_backend'
require 'twterm/publisher'
require 'twterm/event/open_uri'

module Twterm
  module PhotoViewerBackend
    class BrowserBackend < AbstractPhotoViewerBackend
      include Publisher

      def view(url)
        event = Event::OpenURI.new(url)
        publish(event)
      end
    end
  end
end
