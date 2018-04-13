require 'twterm/photo_viewer_backend/abstract_photo_viewer_backend'

module Twterm
  module PhotoViewerBackend
    class QuickLookBackend < AbstractPhotoViewerBackend
      def view(url)
        with_downloaded_file(url) do |file|
          `qlmanage -p #{file.path} 2>/dev/null`
        end
      end
    end
  end
end
