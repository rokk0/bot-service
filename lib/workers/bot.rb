class BotWorker

  include Logging

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
    logger.info "starting bot"

    bot = decrypt(bot)

    Core::Scheduler.add_job(bot)
  rescue
    { :status => :error, :message => 'data error' }
  end

  def self.stop(bot)
    bot = decrypt(bot)

    Core::Scheduler.remove_job(bot['id'])
  rescue
    { :status => :error, :message => 'data error' }
  end

  def self.stop_account_bots(account)
    account = decrypt(account)

    Core::Scheduler.remove_account_jobs(account['account_id'])
  rescue
    { :status => :error, :message => 'data error' }
  end

  def self.stop_user_bots(user)
    user = decrypt(user)

    Core::Scheduler.remove_user_jobs(user['user_id'])
  rescue
    { :status => :error, :message => 'data error' }
  end

  def self.get_account_bots(account_id)
    jobs = Core::Scheduler.get_account_jobs(account_id)

    create_bots_hash(jobs)
  end

  def self.get_user_bots(user_id)
    jobs = Core::Scheduler.get_user_jobs(user_id)

    create_bots_hash(jobs)
  end

  # Create hash like { "<bot_id>" => { :status => "<bot_status>", :message => "<status_message>" } }
  # from bot tags ["user_<id>", "account_<id>", "bot_<id>", "<bot_status>", "<status_message>"]
  def self.create_bots_hash(jobs)
    bots = {}

    jobs.each do |job|
      bot_id       = job.tags[2].scan(/bot_(\d+)/).flatten.first
      bots[bot_id] = { :status => job.tags[3], :message => job.tags[4]} unless bot_id.nil?
    end

    bots
  end

  def self.approve(account)
     account = decrypt(account)

     @vk = Core::Vk.new(account['phone'], account['password'], nil)
     @vk.login
     @vk.bot_status
   rescue
    { :status => :error, :message => 'data error' }
  end

  def self.check_session(account)
    account = decrypt(account)
    session = !eval("defined? $account_#{account['id']}").nil? && eval("$account_#{account['id']}.logged_in?")

    unless session
      vk = Core::Vk.new(account['phone'], account['password'], nil)
      vk.login
      session = vk.logged_in?

      eval("$account_#{account['id']} = vk")
    end

    { :session => session }
  rescue
    { :session => false }
  end

  def self.decrypt(data)
    decrypted_value = Encryptor.decrypt(data, :key => $secret_key)
    JSON.parse(decrypted_value)
  rescue
    nil
  end

end
