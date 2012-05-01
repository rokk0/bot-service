require_relative '../core/vk'
require_relative '../bots/group'
require_relative '../bots/discussion'
require 'encryptor'

class BotWorker

  def initialize(bot)
    @bot = eval("Bots::#{bot['bot_type'].capitalize}").new(bot)
  end

  def id
    @bot.id
  end

  def status
    @bot.bot_status[:status]
  end

  def message
    @bot.bot_status[:message]
  end

  def get_worker_status
    status = { :status => @bot.bot_status[:status], :message => @bot.bot_status[:message] }

    unless status[:status] == :error
      if @bot.page_hash.empty?
        status[:page_hash] = @bot.get_hash(@bot.page)
      end

      if @bot.page_title.empty?
        status[:page_title] = @bot.get_page_title(@bot.page)
      end
    end

    status
  end

  def run
    if @bot.logged_in?
      @bot.spam
    end
  end

  def self.decrypt(data)
    decrypted_value = Encryptor.decrypt(data, :key => $secret_key)
    JSON.parse(decrypted_value)
  rescue
    nil
  end

end
