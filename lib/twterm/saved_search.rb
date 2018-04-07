module Twterm
  class SavedSearch
    attr_reader :id, :query

    def initialize(saved_search)
      @id = saved_search.id
      @query = saved_search.query
    end
  end
end
