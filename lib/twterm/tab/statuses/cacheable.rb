module Twterm
  module Tab
    module Statuses
      module Cacheable
        def retrieve_from_cache!
          statuses = cached_statuses
          cached_statuses.each { |status| append(status) }

          unless statuses.empty?
            sort
            scroller.move_to_top
            initially_loaded!
          end
        end
      end
    end
  end
end
