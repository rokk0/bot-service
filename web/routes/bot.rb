# Should return bot info
# {
#   :status => :running/:stopped/:error
#   :id =>
#   ...
# }

# Should approve account login
post '/api/account/approve/?' do
  BotWorker.approve(params[:account]).to_json
end

# Should return bot status
get '/api/bot/:id' do
  job = Core::Scheduler.get_bot_job(params[:id])
  { :running => job.empty? ? false : true }.to_json
end

# Should run the bot
post '/api/bot/run/?' do
  BotWorker.run(params[:bot]).to_json
end

# Should stop the bot
post '/api/bot/stop/?' do
  BotWorker.stop(params[:bot]).to_json
end

# Should stop account user bots
post '/api/bot/stop_account_bots/?' do
  BotWorker.stop_account_bots(params[:account]).to_json
end

# Should stop all user bots
post '/api/bot/stop_user_bots/?' do
  BotWorker.stop_user_bots(params[:user]).to_json
end

# Should return user bots
get '/api/user/:id/bots' do
  BotWorker.get_user_bots(params[:id]).to_json
end
