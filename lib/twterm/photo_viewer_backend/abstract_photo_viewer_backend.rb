require 'concurrent'

module Twterm
  module PhotoViewerBackend
    # @abstract
    class AbstractPhotoViewerBackend
      # @abstract
      def view(_url)
        raise NotImplementedError, '`view` method must be implemented'
      end

      private

      def getc
        system('stty raw -echo')
        STDIN.getc
      ensure
        system('stty -raw echo')
      end

      # @param url [#to_s]
      # @yieldparam file [File]
      def with_downloaded_file(url, &block)
        uri = URI.parse(url)

        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          http.verify_mode = OpenSSL::SSL::VERIFY_PEER
          res = http.get(uri.path)

          case res
          when Net::HTTPSuccess
            Tempfile.open(['', '.jpg'], Dir.tmpdir) do |file|
              file.binmode
              file.write(res.body)
              file.flush

              block.call(file)
            end
          else
            raise res
          end
        end
      end
    end
  end
end
