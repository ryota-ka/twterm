require 'twterm/friendship'
require 'twterm/repository//abstract_repository'

module Twterm
  module Repository
    class FriendshipRepository < AbstractRepository
      private :create

      def initialize
        super

        @user_ids = Set.new
      end

      def already_looked_up?(user_id)
        @user_ids.include?(user_id)
      end

      def block(from, to)
        create(:blocking, from, to)
      end

      def blocking?(from, to)
        !find([:blocking, from, to]).nil?
      end

      def cancel_follow_request(from, to)
        create(:following_requested, from, to)
      end

      def delete(status, from, to)
        repository[status].delete_if { |f| f.status == status && f.from == from && f.to == to }
      end

      def follow(from, to)
        create(:following, from, to)
      end

      def following?(from, to)
        !find([:following, from, to]).nil?
      end

      def following_not_requested(from, to)
        delete(:following_requested, from, to)
      end

      def following_requested(from, to)
        create(:following_requested, from, to)
      end

      def following_requested?(from, to)
        !find([:following_requested, from, to]).nil?
      end

      def looked_up!(user_id)
        @user_ids << user_id
        user_id
      end

      def mute(from, to)
        create(:muting, from, to)
      end

      def muting?(from, to)
        !find([:muting, from, to]).nil?
      end

      def unblock(from, to)
        delete(:blocking, from, to)
      end

      def unfollow(from, to)
        delete(:following, from, to)
      end

      def unmute(from, to)
        delete(:muting, from, to)
      end

      private

      def find(key)
        status, from, to = key

        repository[status].find { |f| f.from == from && f.to == to }
      end

      def extract_key(args)
        args
      end

      def empty_repository
        Friendship::STATUSES.map { |s| [s, []] }.to_h
      end

      def store(instance)
        repository[instance.status] << instance
      end

      def type
        Friendship
      end
    end
  end
end
