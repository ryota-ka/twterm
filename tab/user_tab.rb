module Tab
  class UserTab
    include StatusesTab

    attr_reader :user

    def initialize(user)
      fail ArgumentError, 'argument must be an instance of User class' unless user.is_a? User

      super()

      @user = user
      @title = "@#{user.screen_name}"

      fetch { move_to_top }
      auto_reload(120) { fetch }
    end

    def fetch
      ClientManager.instance.current.user_timeline(@user.id) do |statuses|
        statuses.reverse.each { |status| prepend(status) }
        sort
        yield if block_given?
      end
    end
  end
end
