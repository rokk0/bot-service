# Should return bot info
# {
#   :status => :running/:stopped/:error
#   :id =>
#   ...
# }

# Should return bot's status
get '/api/bot/:id' do
  job = Core::Scheduler.get_bot_job(params[:id])
  { :running => job.empty? ? false : true }.to_json
end

# Should run the bot
post '/api/bot/run/?' do
  bot = BotWorker.decrypt(params[:bot])

  status = { :status => :error, :message => 'data error'}.to_json

  status = Core::Scheduler.add_job(bot) unless bot.nil?

  status
end

# Should stop the bot
post '/api/bot/stop/?' do
  bot = BotWorker.decrypt(params[:bot])

  status = { :status => :error, :message => 'data error' }.to_json

  unless bot.nil?
    Core::Scheduler.remove_job(bot['id'])

    status = { :status => :stopped, :message => 'stopped' }.to_json
  end

  status
end

# Should return user's bots
get '/api/user/:id/bots' do
  bots = Core::Scheduler.get_user_bots(params[:id])
end
