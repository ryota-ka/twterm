module Twterm
  class List
    attr_reader :id, :name, :slug, :full_name, :mode, :description, :member_count, :subscriber_count, :url

    def ==(other)
      other.is_a?(self.class) && id == other.id
    end

    def initialize(list)
      @id = list.id
      update!(list)
    end

    def update!(list)
      @name = list.name
      @slug = list.slug
      @full_name = list.full_name
      @mode = list.mode
      @description = list.description.is_a?(Twitter::NullObject) ? '' : list.description
      @member_count = list.member_count
      @subscriber_count = list.subscriber_count
      @url = list.url

      self
    end
  end
end
