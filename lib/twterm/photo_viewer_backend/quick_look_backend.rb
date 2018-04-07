require 'twterm/photo_viewer_backend/abstract_photo_viewer_backend'

module Twterm
  module PhotoViewerBackend
    class QuickLookBackend < AbstractPhotoViewerBackend
      def view(photo)
        with_downloaded_file(photo.media_url_https) do |file|
          `qlmanage -p #{file.path} 2>/dev/null`
        end
      end
    end
  end
end
