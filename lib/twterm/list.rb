module Twterm
  class List
    attr_reader :id, :name, :slug, :full_name, :mode, :description, :member_count, :subscriber_count

    @@instances = {}

    def ==(other)
      other.is_a?(self.class) && id == other.id
    end

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

      self
    end

    def self.all
      @@instances.values
    end

    def self.find(id)
      @@instances[id]
    end

    def self.find_or_fetch(id)
      Promise.new do |resolve, reject|
        instance = find(id)
        (resolve.(instance) && next) if instance

        Client.current.list(id).then { |list| resolve.(list) }
      end
    end

    def self.new(list)
      instance = find(list.id)
      instance.nil? ? super : instance.update!(list)
    end
  end
end
