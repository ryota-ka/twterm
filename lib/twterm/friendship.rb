module Twterm
  class Friendship
    STATUSES = %i(
      blocking
      following
      following_requested
      muting
    ).freeze

    attr_reader :status, :from, :to

    @@instances = []
    @@user_ids = Set.new

    def initialize(status, from, to)
      fail ArgumentError,
        '' unless STATUSES.include? status

      @status, @from, @to = status, from, to
      @@instances << self
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

    def self.already_looked_up?(user_id)
      @@user_ids.include?(user_id)
    end

    def self.block(from, to)
      new(:blocking, from, to)
    end

    def self.blocking?(from, to)
      !find(:blocking, from, to).nil?
    end

    def self.cancel_follow_request(from, to)
      new(:following_requested, from, to)
    end

    def self.delete(status, from, to)
      cond = -> f { f.status == status && f.from == from && f.to == to }
      @@instances.delete_if(&cond)
    end
    private_class_method :delete

    def self.find(status, from, to)
      cond = -> f { f.status == status && f.from == from && f.to == to }
      @@instances.find(&cond)
    end
    private_class_method :find

    def self.follow(from, to)
      new(:following, from, to)
    end

    def self.following?(from, to)
      !find(:following, from, to).nil?
    end

    def self.following_not_requested(from, to)
      delete(:following_requested, from, to)
    end

    def self.following_requested(from, to)
      new(:following_requested, from, to)
    end

    def self.following_requested?(from, to)
      !find(:following_requested, from, to).nil?
    end

    def self.looked_up!(user_id)
      @@user_ids << user_id
      user_id
    end

    def self.mute(from, to)
      new(:muting, from, to)
    end

    def self.muting?(from, to)
      !find(:muting, from, to).nil?
    end

    def self.new(status, from, to)
      instance = find(status, from, to)
      instance.nil? ? super : instance
    end
    private_class_method :new

    def self.unblock(from, to)
      delete(:blocking, from, to)
    end

    def self.unfollow(from, to)
      delete(:following, from, to)
    end

    def self.unmute(from, to)
      delete(:muting, from, to)
    end

    private

    def status?(status)
      self.status == status
    end
  end
end
