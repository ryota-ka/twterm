module Tab
  class UserTab
    include StatusesTab

    attr_reader :user_id

    def initialize(user_id)
      super()

      @user_id = user_id

      Thread.new do
        ClientManager.instance.current.user_timeline(@user_id).reverse.each do |status|
          push(status)
        end
      end
    end
  end
end
