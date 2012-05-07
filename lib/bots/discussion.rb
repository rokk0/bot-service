module Bots
  class Discussion < Core::Vk

    attr_reader :id, :page, :page_title, :page_hash

    def initialize(bot)
      if $accounts[bot['account_id']].nil? || !$accounts[bot['account_id']].logged_in?
        vk = Core::Vk.new(bot['phone'], bot['password'])
        vk.login

        $accounts[bot['account_id']] = vk
      end

      @vk = $accounts[bot['account_id']]

      @id             = bot['id']
      @user_id        = bot['user_id']
      @count          = (1..8).member?(bot['count'].to_i) ? bot['count'].to_i : 1
      @page           = bot['page']
      @discussion_id  = '-' + @page[/\d+_\d+/].to_s
      @page_hash      = bot['page_hash']
      @message        = bot['message']
      @page_title     = bot['page_title']
      @msg_count      = 0
    end

    def bot_status
      @vk.bot_status
    end

    def get_hash(page)
      page = @vk.agent.get(page)
      @vk.parse_page(page, /hash:\s'([^.]\w*)'/)
    end

    def get_page_title(page)
      @vk.get_page_title(page)
    end

    def spam
      @vk.check_login

      if @vk.logged_in?
        params = {
          :act      => 'post_comment',
          :topic    => @discussion_id,
          :hash     => @page_hash.empty? ? get_hash(@page) : @page_hash,
          :comment  => @message,
          :al       => '1'
        }

        @count.times do
          @msg_count += 1
          params[:comment] = "#{@message}\n\n#{(rand(9999999999) + 100000000)}"
          page = @vk.agent.post('http://vk.com/al_board.php', params, { 'Referer' => @page })

          @vk.check_post_response(page.body)
          p "user:#{@user_id}/bot:#{@id} - sending discussion message ##{@msg_count} - status:#{@vk.bot_status[:status]}/message:#{@vk.bot_status[:message]}"
        end
      end
    end

  end
end
