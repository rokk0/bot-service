class BotWorker

  def initialize(bot)
    @bot = eval("Bots::#{bot['bot_type'].capitalize}").new(bot)
  end

  def status
    @bot.bot_status[:status]
  end

  def message
    @bot.bot_status[:message]
  end

  def spam
    @bot.spam
  end

  def get_worker_status
    status = { :status => @bot.bot_status[:status], :message => @bot.bot_status[:message] }

    unless status[:status] == :error
      status[:page_hash]  = @bot.get_hash(@bot.page) if @bot.page_hash.empty?
      status[:page_title] = @bot.get_page_title(@bot.page) if @bot.page_title.empty?
    end

    status
  end

  def self.run(bot)
    bot = decrypt(bot)

    status = { :status => :error, :message => 'data error' }

    status = Core::Scheduler.add_job(bot) unless bot.nil?

    status
  end

  def self.stop(bot)
    bot = decrypt(bot)

    status = { :status => :error, :message => 'data error' }

    status =  Core::Scheduler.remove_job(bot['id']) unless bot.nil?

    status
  end

  def self.stop_user_bots(user)
    user = decrypt(user)

    status = { :status => :error, :message => 'data error' }

    status =  Core::Scheduler.remove_user_jobs(user['user_id']) unless user.nil?

    status
  end

  def self.get_user_bots(user_id)
    jobs      = Core::Scheduler.get_user_jobs(user_id)
    job_tags  = {}
    bots      = {}

    # Create hash like { "<bot_id>" => { :status => "<bot_status>", :message => "<status_message>" } }
    # from bot tags ["user_<id>", "bot_<id>", "<bot_status>", "<status_message>"]
    jobs.each do |job|
      bot_id       = job.tags[1].scan(/bot_(\d+)/).flatten.first
      bots[bot_id] = { :status => job.tags[2], :message => job.tags[3]} unless bot_id.nil?
    end

    bots
  end

  def self.decrypt(data)
    decrypted_value = Encryptor.decrypt(data, :key => $secret_key)
    JSON.parse(decrypted_value)
  rescue
    nil
  end

end
