module Twterm
  class Friendship
    STATUSES = %i(
      blocking
      following
      following_requested
      muting
    ).freeze

    attr_reader :status, :from, :to

    def initialize(status, from, to)
      fail ArgumentError, '`status` must be one of the following: :blocking, :follwing, :following_requested, or :muting' unless STATUSES.include? status

      @status, @from, @to = status, from, to
    end

    def blocking?
      status?(:blocking)
    end

    def following?
      status?(:following)
    end

    def following_requested?
      status?(:following_requested)
    end

    def muting?
      status?(:muting)
    end

    private

    def status?(status)
      self.status == status
    end
  end
end
