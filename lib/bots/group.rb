module Bots
  class Group < Core::Vk

    attr_reader :id, :page, :page_title, :page_hash

    def initialize(bot)
      @vk = Core::Vk.new(bot['email'], bot['password'], bot['code'], bot['page'])

      @id         = bot['id']
      @user_id    = bot['user_id']
      @count      = (1..8).member?(bot['count'].to_i) ? bot['count'].to_i : 1
      @page       = bot['page']
      @group_id   = '-' + @page[/\d+/].to_s
      @page_hash  = bot['page_hash']
      @message    = bot['message']
      @page_title = bot['page_title']
      @msg_count  = 0

      @vk.login
    end

    def logged_in?
      @vk.logged_in?
    end

    def bot_status
      @vk.bot_status
    end

    def get_hash(page)
      page = @vk.agent.get(page)

      @page_hash = @vk.parse_page(page, /"post_hash":"([^.]\w*)"/)
    end

    def spam
      params = {
        :act      => 'post',
        :hash     => @page_hash,
        :type     => 'all',
        :message  => @message,
        :to_id    => @group_id,
        :al       => '1'
      }

      @vk.check_login

      @count.times do
        @msg_count += 1
        params[:message] = "#{@message}\n\n#{(rand(9999999999) + 100000000)}"
        page = @vk.agent.post('http://vk.com/al_wall.php', params, { 'Referer' => @page })

        @vk.check_captcha(page.body)
        p "user:#{@user_id}/bot:#{@id} - sending group message ##{@msg_count} - status:#{@vk.bot_status[:status]}/message:#{@vk.bot_status[:message]}"
      end if @vk.logged_in?
    end

  end
end
