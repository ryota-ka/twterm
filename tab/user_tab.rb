module Tab
  class UserTab
    include StatusesTab

    attr_reader :user

    def initialize(user)
      fail ArgumentError, 'argument must be an instance of User class' unless user.is_a? User

      super()

      @user = user
      @title = "@#{user.screen_name}"

      Thread.new do
        ClientManager.instance.current.user_timeline(@user.id).reverse.each do |status|
          push(status)
        end
      end
    end
  end
end
