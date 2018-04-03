require 'twterm/photo_viewer_backend/abstract_photo_viewer_backend'
require 'twterm/publisher'
require 'twterm/event/open_uri'

module Twterm
  module PhotoViewerBackend
    class BrowserBackend < AbstractPhotoViewerBackend
      include Publisher

      def view(photo)
        event = Event::OpenURI.new(photo.media_url_https)
        publish(event)
      end
    end
  end
end
