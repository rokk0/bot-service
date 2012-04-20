# Should return bot info
# {
#   :status => :running/:paused/:stopped
#   :id => 
#   ...
# }
get '/api/bot/:id' do
end

# Should turn on the bot
get '/api/bot/:id/run' do
  Resque.enqueue(RunBot, params[:id]) 
end

# Should put the bot on hold
get '/api/bot/:id/pause' do
end

# Should stop the bot
get '/api/bot/:id/stop' do
end
