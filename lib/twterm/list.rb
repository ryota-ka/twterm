module Twterm
  # A Twitter list
  class List
    # Unique ID of the list
    #
    # @return [Integer]
    attr_reader :id

    # @return [String]
    attr_reader :name

    # @return [String]
    attr_reader :slug

    # @return [String]
    attr_reader :full_name

    attr_reader :mode

    # @return [String]
    attr_reader :description

    # The number of users that are in this list
    #
    # @return [Integer]
    attr_reader :member_count

    # The number of users that subscribe this list
    #
    # @return [Integer]
    attr_reader :subscriber_count

    # @return [String]
    attr_reader :url

    # @param other [List]
    #
    # @return [Boolean]
    def ==(other)
      other.is_a?(self.class) && id == other.id
    end

    def initialize(list)
      @id = list.id
      update!(list)
    end

    # @return [self]
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
