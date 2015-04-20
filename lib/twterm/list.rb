module Twterm
  class List
    attr_reader :id, :name, :slug, :full_name, :mode, :description, :member_count, :subscriber_count

    @@instances = {}

    def initialize(list)
      @id = list.id
      update!(list)

      @@instances[@id] = self
      self
    end

    def update!(list)
      @name = list.name
      @slug = list.slug
      @full_name = list.full_name
      @mode = list.mode
      @description = list.description.is_a?(Twitter::NullObject) ? '' : list.description
      @member_count = list.member_count
      @subscriber_count = list.subscriber_count
    end

    def ==(other)
      other.is_a?(self.class) && id == other.id
    end

    def self.new(list)
      instance = find(list.id)
      instance.nil? ? super : instance.update!(list)
    end

    def self.find(id)
      @@instances[id]
    end

    def self.find_or_fetch(id)
      instance = find(id)
      (yield(instance) && return) if instance

      Client.current.list(id) { |list| yield list }
    end

    def self.all
      @@instances.values
    end
  end
end
