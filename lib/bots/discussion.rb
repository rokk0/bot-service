module Bots
  class Discussion < Core::Vk

    include Logging

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

    def get_page_hash(page)
      page = @vk.agent.get(page)
      @vk.get_page_hash(page, /hash:\s'([^.]\w*)'/)
    rescue Exception => e
      logger.error "Error while getting discussion page hash: #{e.message}"
      nil
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
          :hash     => @page_hash.empty? ? get_page_hash(@page) : @page_hash,
          :comment  => @message,
          :al       => '1'
        }

        @msg_count += 1
        params[:comment] = "#{@message}\n\n#{(rand(9999999999) + 100000000)}"
        page = @vk.agent.post('http://vk.com/al_board.php', params, { 'Referer' => @page })

        @vk.check_post_response(page.body)
        logger.info "user:#{@user_id}/bot:#{@id} - sending discussion message ##{@msg_count} - status:#{@vk.bot_status[:status]}/message:#{@vk.bot_status[:message]}"
      end
    end

  end
end
