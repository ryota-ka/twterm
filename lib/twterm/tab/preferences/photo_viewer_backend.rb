require 'twterm/image'
require 'twterm/preferences'
require 'twterm/publisher'
require 'twterm/tab/abstract_tab'
require 'twterm/tab/scrollable'

module Twterm
  module Tab
    module Preferences
      class PhotoViewerBackend < AbstractTab
        include Scrollable
        include Publisher

        def drawable_item_count
          (window.maxy - 1) / 2
        end

        def image
          drawable_items.map.with_index do |item, i|
            curr = scroller.current_index?(i)
            cursor = Image.cursor(1, curr)
            checkbox = Image.checkbox(app.preferences[:photo_viewer_backend, item])
            desc =
              case item
              when :browser
                'Web browser backend'
              when :imgcat
                'imgcat backend'
              when :quick_look
                'Quick Look backend'
              end

              cursor - Image.whitespace - checkbox - Image.whitespace - Image.string(desc).bold(curr)
          end
            .intersperse(Image.blank_line)
            .reduce(Image.empty) { |acc, x| acc | x }
        end

        def items
          env = app.environment

          [
            :browser,
            (:imgcat if env.with_imgcat?),
            (:quick_look if env.with_qlmanage?),
          ].compact
        end

        def respond_to_key(key)
          return true if scroller.respond_to_key(key)

          case key
          when 10
            perform_selected_action
          end

          false
        end

        def title
          'Photo viewer backend preferences'
        end

        private

        def perform_selected_action
          item = scroller.current_item

          case item
          when :browser
            app.preferences[:photo_viewer_backend, :browser] =
              !app.preferences[:photo_viewer_backend, :browser]
          when :imgcat
            app.preferences[:photo_viewer_backend, :imgcat] =
              !app.preferences[:photo_viewer_backend, :imgcat]
          when :quick_look
            app.preferences[:photo_viewer_backend, :quick_look] =
              !app.preferences[:photo_viewer_backend, :quick_look]
          end

          render
        end
      end
    end
  end
end
