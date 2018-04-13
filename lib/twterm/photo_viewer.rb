require 'twterm/event/open_photo'
require 'twterm/photo_viewer_backend/browser_backend'
require 'twterm/photo_viewer_backend/imgcat_backend'
require 'twterm/photo_viewer_backend/quick_look_backend'
require 'twterm/subscriber'

module Twterm
  class PhotoViewer
    include Subscriber

    # @param preferences [Twterm::Preferences]
    def initialize(preferences)
      @preferences = preferences

      @backends = {
        browser: PhotoViewerBackend::BrowserBackend.new,
        imgcat: PhotoViewerBackend::ImgcatBackend.new,
        quick_look: PhotoViewerBackend::QuickLookBackend.new,
      }

      subscribe(Event::OpenPhoto) { |n| view(n.photo) }
    end

    private

    attr_reader :backends, :preferences

    # @param url [Addressable::URI]
    # @return [void]
    def view(url)
      backends.each do |key, backend|
        backend.view(url) if preferences[:photo_viewer_backend, key]
      end
    end
  end
end
